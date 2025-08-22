import groovy.json.JsonGenerator
import groovy.json.JsonGenerator.Converter

nextflow.enable.dsl=2

// comes from nf-test to store json files
params.nf_test_output  = ""

// include dependencies


// include test process
include { metadata2sqlite } from '/home/guyoldrieve/git/btb-forestry/main.nf'

// define custom rules for JSON that will be generated.
def jsonOutput =
    new JsonGenerator.Options()
        .addConverter(Path) { value -> value.toAbsolutePath().toString() } // Custom converter for Path. Only filename
        .build()

def jsonWorkflowOutput = new JsonGenerator.Options().excludeNulls().build()


workflow {

    // run dependencies
    

    // process mapping
    def input = []
    
                input[0] =  file("/home/guyoldrieve/git/btb-forestry/tests/data/filterMeta_exp.csv")
                input[1] =  file("/home/guyoldrieve/git/btb-forestry/tests/data/metaTest.csv")
                input[2] =  file("/home/guyoldrieve/git/btb-forestry/tests/data/moveTest.csv")
                input[3] =  file("/home/guyoldrieve/git/btb-forestry/tests/data/location.csv")
                input[4] =  file("/home/guyoldrieve/git/btb-forestry/tests/data/excluded_exp.csv")
                
    //----

    //run process
    metadata2sqlite(*input)

    if (metadata2sqlite.output){

        // consumes all named output channels and stores items in a json file
        for (def name in metadata2sqlite.out.getNames()) {
            serializeChannel(name, metadata2sqlite.out.getProperty(name), jsonOutput)
        }	  
      
        // consumes all unnamed output channels and stores items in a json file
        def array = metadata2sqlite.out as Object[]
        for (def i = 0; i < array.length ; i++) {
            serializeChannel(i, array[i], jsonOutput)
        }    	

    }
  
}

def serializeChannel(name, channel, jsonOutput) {
    def _name = name
    def list = [ ]
    channel.subscribe(
        onNext: {
            list.add(it)
        },
        onComplete: {
              def map = new HashMap()
              map[_name] = list
              def filename = "${params.nf_test_output}/output_${_name}.json"
              new File(filename).text = jsonOutput.toJson(map)		  		
        } 
    )
}


workflow.onComplete {

    def result = [
        success: workflow.success,
        exitStatus: workflow.exitStatus,
        errorMessage: workflow.errorMessage,
        errorReport: workflow.errorReport
    ]
    new File("${params.nf_test_output}/workflow.json").text = jsonWorkflowOutput.toJson(result)
    
}
