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
@test "Test where unable to source imod script" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  # Write out to command.tasks file under bin directory
  # When $THE_TMP/bin/command is invoked it will read
  # from command.tasks file and execute the command
  # in it following this format: exit code,std out,std err,command to execute
  #
  # Note: the command to execute ie echo will be given all the arguments passed to the command
  #
  echo "hi" > "$THE_TMP/yo.mrc"

  # Run kepler.sh
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -CWS_outputdir $THE_TMP -mrcfile "$THE_TMP" -imodSourceScript "$THE_TMP/doesnotexist" $WF

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
  [ "${lines[0]}" == "simple.error.message=Unable to load imod configuration" ]
  [ "${lines[1]}" == "detailed.error.message=Unable to source $THE_TMP/doesnotexist" ]


  # Verify we got a README.txt
  [ -s "$THE_TMP/$README_TXT" ]
  
  # Check we got a workflow.status file
  [ -s "$THE_TMP/$WORKFLOW_STATUS" ]

}
 
