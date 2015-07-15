#!/usr/bin/env bats


# 
# Load the helper functions in test_helper.bash 
# Note the .bash suffix is omitted intentionally
# 
load test_helper

#
# Test to run is denoted with at symbol test like below
# the string after is the test name and will be displayed
# when the test is run
#
# This test uses the command script under the bin/ directory
# to simulate a failed command to verify the workflow
# properly handles the failure
#
@test "Test copy of mrc fails" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  # Write out to command.tasks file under bin directory
  # When $THE_TMP/bin/command is invoked it will read
  # from command.tasks file and execute the command
  # in it following this format: exit code,std out,std err,command to execute
  #
  # Note: the command to execute ie echo will be given all the arguments passed to the command
  #
  echo "0,hi,," > "$THE_TMP/bin/command.tasks"
  echo "1,,lnerror" >> "$THE_TMP/bin/command.tasks"
  echo "1,,cperror," >> "$THE_TMP/bin/command.tasks"
  mkdir -p "$THE_TMP/foo/data"
  echo "hi" > "$THE_TMP/foo/data/yo.mrc"
  echo "hi=1" > "$THE_TMP/imod.sh"

  # Run kepler.sh
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -CWS_outputdir $THE_TMP -mrcfile "$THE_TMP/foo" -clipCmd "$THE_TMP/bin/command" -imodSourceScript "$THE_TMP/imod.sh" -lnCmd "$THE_TMP/bin/command" -cpCmd "$THE_TMP/bin/command" $WF

  # Check exit code, kepler is always zero even if it fails
  # which is why we have a WORKFLOW.FAILED.txt file
  [ "$status" -eq 0 ]

  # will only see this if kepler fails
  echoArray "${lines[@]}"

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  # Will be output if anything below fails
  cat "$THE_TMP/$README_TXT"

  # Verify we got a WORKFLOW.FAILED.txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  echo "WORKFLOW FAILED"
  cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  echo ""
  [ "${lines[0]}" == "simple.error.message=Problems copying MRC file to Workspace" ]
  [ "${lines[1]}" == "detailed.error.message=Non zero exitcode (1) from $THE_TMP/bin/command -v $THE_TMP/foo/data/yo.mrc $THE_TMP/data/input.mrc : cperror" ]

  

  # Verify we got a README.txt
  [ -s "$THE_TMP/$README_TXT" ]
  
  # Check we got a workflow.status file
  [ -s "$THE_TMP/$WORKFLOW_STATUS" ]

}
 
