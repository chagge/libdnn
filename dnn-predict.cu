#include <iostream>
#include <string>
#include <dnn.h>
#include <dnn-utility.h>
#include <cmdparser.h>
using namespace std;

int main (int argc, char* argv[]) {

  CmdParser cmd(argc, argv);

  cmd.add("testing_set_file")
    .add("model_file")
    .add("output_file", false);

  cmd.addGroup("Prediction options: ")
    .add("--itr", "number of maximum iteration", "inf")
    .add("--type", "choose one of the following:\n"
	"0 -- classfication\n"
	"1 -- regression", "0");

  if (!cmd.isOptionLegal())
    cmd.showUsageAndExit();

  string test_fn = cmd[1];
  string model_fn = cmd[2];
  string output_fn = cmd[3];

  DataSet test;
  getFeature(test_fn, test);

  showSummary(test);

  DNN dnn(model_fn);
  mat prob = dnn.predict(test);

  ERROR_MEASURE errorMeasure = CROSS_ENTROPY;

  if (isLabeled(test.y)) {
    size_t nError = zeroOneError(prob, test.y, errorMeasure);
    showAccuracy(nError, test.y.size());
  }

  FILE* fid = output_fn.empty() ? stdout : fopen(output_fn.c_str(), "w");
  if (fid == NULL) {
    fprintf(stderr, "Failed to open output file");
    return -1;
  }

  mat predictions = posteriorProb2Label(prob);
  predictions.print(fid);

  if (fid != stdout)
    fclose(fid);

  return 0;
}

