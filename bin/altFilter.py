#!/usr/bin/env python3

import allel
import pandas as pd
from Bio import SeqIO
import time
import argparse
import sys

st = time.time()


def altFilter(noc_vcf, dashc_vcf, noc_fas, clade):

    # import vcf data into dataframe, this is used to select the positions
    # for the N's

    data = pd.DataFrame(allel.vcf_to_dataframe(noc_vcf, fields='POS'))
    data_c = pd.DataFrame(allel.vcf_to_dataframe(dashc_vcf, fields='POS'))

# find the sites that have been lost in the -c, these sites contain a
# sample that has a N
    diff = pd.concat([data, data_c]).drop_duplicates(keep=False).reset_index(drop=True)
# get data required from the snp.fasta file (not -c) and tranform this
# into a dataframe
# this contains all of the fasta data for the samples set
    seq_record = []
    fasta_id = []
    fasta_seq = []

    for seq_record in SeqIO.parse(noc_fas, "fasta"):
        fasta_id.append(seq_record.id)
        fasta_seq.append(seq_record.seq)

    seq_df = pd.DataFrame({"Sample ID": fasta_id,
                           "Sample Sequence": fasta_seq})

# create a dataframe which will calculate the % of Ns that are in each SNP
# site cycle through the entire length of sequence and for each pos, it will
# go through every base in all samples and see if there is an N present.
# Then, if we divide the num of N by the length of the sequence and if this
# is not 0, we can add the base and the % of N to a list
# Lastly, it will check to see if n_count_df is empty, if it is it will create
# an empty dropped list for the clade and exit the script
    n_count_df = pd.DataFrame(columns=["Base", "N %"])
    counter = 0
    num_of_N = 0

    for num_of_bases in range(len(seq_record)):
        counter = counter + 1
        num_of_N = 0
        for sample in seq_df["Sample Sequence"]:
            x_base = (sample[num_of_bases])
            if x_base == "N":
                num_of_N = num_of_N + 1
        if (num_of_N/len(fasta_id)) != 0:
            temp = {"Base": [counter], "N %": [(num_of_N/len(fasta_id))]}
            temp = pd.DataFrame(temp)
            n_count_df = pd.concat([temp, n_count_df]).sort_values("Base")\
                .reset_index(drop=True)
    if n_count_df.empty:
        empty = {"Samples": []}
        droppedSamples_df = pd.DataFrame(empty)
        droppedSamples_df.to_csv('{}_dropped.csv'.format(clade), index=False)
        sys.exit()


# Combine the diff and n_count_df and change the names of the columns in the
# database, pos is the genome pos, fasta is the fasta pos and %N is the
# number of Ns
    n_count_df = pd.concat([diff, n_count_df], ignore_index=True, axis=1)
    n_count_df = n_count_df.rename(columns={0: "POS", 1: "Fasta Base", 2:
                                            "N %"})

# find which samples have a N at that position, first we get the position in
# the Ns in the fasta file. We then go through the dataframe which contains
# all the seq data, we can see which samples contains N at a certain fasta
# position, this is them combined in a df
    final = pd.DataFrame()

    for base in n_count_df["Fasta Base"]:
        base_N = []
        for samples in seq_df.itertuples():
            if samples._2[(int(base)-1)] == "N":
                base_N.append(samples._1)
        base_N = ":".join(base_N)
        temp = pd.DataFrame([base_N])
        final = pd.concat([final, temp], axis=0, ignore_index=True)

    n_count_df['3'] = final

# export n_count_df to a csv ?required
    n_count_df.to_csv("n_count.csv", index=False)

# find a total list of samples that need to be parsed, then the
# collated samples will recreate the 3rd column of the dataframe in a
# parseable format, then all the samples a unlisted and the duplciated
# removed. Output these samples in a csv and then create a new dataframe which
# creates the outline for the scoring

    sample = n_count_df['3'].tolist()
    amples = []

    for collated_samples in sample:
        amples.append(collated_samples.split(":"))

    samples = [i for b in map(lambda x:[x] if not isinstance(x, list) else x,
               amples) for i in b]
    samples = list(set(samples))

    df = pd.DataFrame(samples)
    df = pd.DataFrame(columns=["Samples", "%", "No of Ns", "Unique Ns",
                               "Non-unique Ns"])

# find non-unique N samples (samples that have Ns in sites where other
# samples so aswell). To do this a list is made for each fasta pos which
# contains a N and the number of posistions which have more then one samples
# (which a N). Then a list is made which contains all these positions which
# have multiples samples with Ns in them
    pop_list = []
    counter = 0
    for strain in amples:
        if len(strain) == 1:
            pop_list.append(counter)
        counter = counter + 1

    unique_not = list(amples)
    for remove in reversed(pop_list):
        unique_not.pop(remove)

# find unique N samples (samples has a N in a site not other sample does), in
# essence it does the same thing a above, create a list of all the non-unique
# sites and remove them to leave the unqiue sites
    pop_list = []
    counter = 0
    for strain in amples:
        if len(strain) > 1:
            pop_list.append(counter)
        counter = counter + 1

    unique = list(amples)
    for remove in reversed(pop_list):
        unique.pop(remove)
    unique = [item for sublist in unique for item in sublist]

# This section parses through all the samples which have Ns, first we parse
# all the samples which contain a N, we then prase through all the pos which
# contains a single sample, if the samples matches, we had a unique score of
# one(while the samples could also be here, it is combined with other samples),
# then we can parse the non-unique to do the samples thing (however this time
# they are in a list so it will work). All this infromation is combined into
# a single df and them outputed for every sample.
    length = len(sample)
    for strain in samples:
        counter = 0
        counter_2 = 0
        for positions in sample:
            if strain in positions:
                counter = counter + 1
        uni_num = unique.count(strain)
        for positions in unique_not:
            if strain in positions:
                counter_2 = counter_2 + 1
        temp = pd.DataFrame({"Samples": [strain], "%": [(counter/length)*100],
                             "No of Ns": [counter], "Unique Ns": uni_num,
                             "Non-unique Ns": counter_2})
        df = pd.concat([temp, df])

# create scoring system for samples, works by looking at all the samples which
# have Ns, then you go through each pos which has a N and see if the sample is
# in it, if it is take the length (number of samples which have Ns in that pos)
# and apply the equation below, it will mean if a sample is unique, then it
# will have a score of 1 while non-unique will have a score of (1/size)**2.
    end = []

    for strain in samples:
        score = 0
        for pos in amples:
            if strain in pos:
                size = len(pos)
                score = score + ((1/size)**2)
        end.append(score)

    end = list(reversed(end))
    df["Score"] = end

# calculate the groups which each sample falls in, these groups correspond to
# the N pos on the genome e.g. if a 2 samples have a N in the same pos then it
# is in a single group. First a list is create with a empty lists which amount
# to the number of samples, we then select pos which have Ns in more then 1
# samples. We then go through all the samples and look to see which group they
# belong to, this is then reversed so that it is in order and added to the df
# [NOT CURRENTLY USED BUT COULD BE APPLIED IN THE FUTURE]
    temp = []
    groups = [[] for _ in range(len(samples))]

    for x in amples:
        if len(x) > 1:
            temp.append(x)
    amples = temp

    counter = 0
    counter_2 = 0
    for x in samples:
        counter = 0
        for y in amples:
            if x in y:
                groups[counter_2].append(counter)
            counter = counter + 1
        counter_2 = counter_2 + 1

    groups.reverse()

    df["Group"] = groups

    df.to_csv("samples.csv", index=False)

# count the number of unique SNPs that a sample has, done similarly to above
    fasta_id = []
    fasta_seq = []

    for seq_record in SeqIO.parse(noc_fas, "fasta"):
        fasta_id.append(seq_record.id)
        fasta_seq.append(seq_record.seq._data)

    df_fin = {"Sample ID": fasta_id, "Sample Sequence": fasta_seq}
    df_fin = pd.DataFrame(data=df_fin)
    counter = -1
    length = len(df_fin["Sample Sequence"][0]) - 1
    unique_SNP_df = pd.DataFrame(columns=["Base Number", "Base", "Sample"])
    non_unique_SNP_df = pd.DataFrame(columns=["Score", "Base", "Sample"])

    for y in range(length):
        counter = counter + 1
        A_counter = 0
        C_counter = 0
        G_counter = 0
        T_counter = 0
        for x in df_fin["Sample Sequence"]:
            if x[counter] == "A":
                A_counter = A_counter + 1
            if x[counter] == "C":
                C_counter = C_counter + 1
            if x[counter] == "G":
                G_counter = G_counter + 1
            if x[counter] == "T":
                T_counter = T_counter + 1
        bases = [A_counter, C_counter, G_counter, T_counter]
        bases.sort(reverse=False)
        smallest = []
        for x in bases:
            if x == 0:
                smallest = 0
                continue
            if x == 1:
                smallest = 1
                break
            else:
                smallest = 0
        base = []
        if smallest == 1:
            if smallest == A_counter:
                base = "A"
            if smallest == C_counter:
                base = "C"
            if smallest == G_counter:
                base = "G"
            if smallest == T_counter:
                base = "T"
        else:
            base = "X"
        counter_2 = 0
        for x in df_fin["Sample Sequence"]:
            if x[counter] == base:
                sample = counter_2
                temp = {"Base Number": y+1, "Base": base, "Sample": counter_2}
                temp = pd.DataFrame([temp])
                unique_SNP_df = pd.concat([temp, unique_SNP_df])
            counter_2 = counter_2 + 1

        m = min(i if i > 1 else len(df_fin) for i in bases)
        if bases.count(1) == 0 and sum(bases) == len(df_fin):
            non_unique_score = ((1/m)**2)
            if m == A_counter:
                nonunique_base = "A"
            if m == C_counter:
                nonunique_base = "C"
            if m == G_counter:
                nonunique_base = "G"
            if m == T_counter:
                nonunique_base = "T"
            else:
                nonunique_base = "X"
            counter_2 = 0
            for x in df_fin["Sample Sequence"]:
                if x[counter] == nonunique_base:
                    sample = counter_2
                    temp = {"Score": non_unique_score, "Base": nonunique_base,
                            "Sample": counter_2}
                    temp = pd.DataFrame([temp])
                    non_unique_SNP_df = pd.concat([temp, non_unique_SNP_df])
                counter_2 = counter_2 + 1

    samples = unique_SNP_df["Sample"].tolist()
    samples.sort(reverse=False)
    unique = list(set(samples))
    SNP_df = pd.DataFrame(columns=["Samples", "Unique SNP"])
    for x in unique:
        freq = samples.count(x)
        temp = {"Samples": fasta_id[x], "Unique SNP": freq}
        temp = pd.DataFrame([temp])
        SNP_df = pd.concat([temp, SNP_df])

    samples = non_unique_SNP_df["Sample"].tolist()
    samples.sort(reverse=False)
    unique = list(set(samples))
    non_SNP_df = pd.DataFrame(columns=["Samples", "Non-Unique SNP Score"])
    for x in unique:
        filtered_df = non_unique_SNP_df[non_unique_SNP_df['Sample'] == x]
        scores = filtered_df["Score"].tolist()
        freq = sum(scores)
        temp = {"Samples": fasta_id[x], "Non-Unique SNP Score": freq}
        temp = pd.DataFrame([temp])
        non_SNP_df = pd.concat([temp, non_SNP_df])

    final_snps_df = pd.merge(non_SNP_df, SNP_df, how="outer")
    final_snps_df = final_snps_df.fillna(0)
    final_snps_df.to_csv("Unique_SNP.csv", index=False)

# combine the unique snps and the samples csv to create a new score, done
# similarly to above

    final_df = pd.merge(df, final_snps_df, how="outer")
    final_df = final_df.fillna(0)

    end = []
    score = []
    samples = final_df["Samples"]
    counter = 0

    for strain in samples:
        x = final_df.loc[final_df["Samples"] == strain]
        score_2 = 0
        for pos in amples:
            if strain in pos:
                size = len(pos)
                score_2 = score_2 + ((1/size)**2)
        non_unique_N = score_2
        if int(x["Unique SNP"]) <= 5:
            score = ((float(x["Unique Ns"])) + float(non_unique_N) +
                     (float(x["Unique SNP"])/15) +
                     (float(x["Non-Unique SNP Score"])/5))
        elif int(x["Unique SNP"]) > 5:
            score = ((float(x["Unique Ns"])) + float(non_unique_N) +
                     (float(x["Unique SNP"])/15) +
                     (float(x["Non-Unique SNP Score"])))
        end.append(score)

    final_df["Score"] = end
    final_df.to_csv('{}_filt.csv'.format(clade), index=False)

# select which samples should be dropped from further anlysis based on score
# greater than 1
    droppedSamples_df = final_df[final_df.Score > 1]
    droppedSamples_df.to_csv('{}_dropped.csv'.format(clade), index=False)


elapsed_time = time.time() - st
print(elapsed_time)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('noc_vcf', help='path to vcf generated without -c')
    parser.add_argument('dashc_vcf', help='path to vcf generated with -c')
    parser.add_argument('noc_fas', help='path to fasta file generated \
                        without -c')
    parser.add_argument('clade', help='clade information')

    args = parser.parse_args()

    altFilter(**vars(args))
