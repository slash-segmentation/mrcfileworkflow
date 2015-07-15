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
@test "Test success with symlink mrc file and hard link works" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  # Write out to command.tasks file under bin directory
  # When $THE_TMP/bin/command is invoked it will read
  # from command.tasks file and execute the command
  # in it following this format: exit code,std out,std err,command to execute
  #
  # Note: the command to execute ie echo will be given all the arguments passed to the command
  #
  echo "0,hello,," > "$THE_TMP/bin/command.tasks"
  mkdir -p "$THE_TMP/foo/data"
  echo "hi" > "$THE_TMP/foo/data/yo.mrc.link"
  ln -s "$THE_TMP/foo/data/yo.mrc.link" "$THE_TMP/foo/data/yo.mrc"
  echo "hi=1" > "$THE_TMP/imod.sh"

  # Run kepler.sh
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -CWS_outputdir $THE_TMP -mrcfile "$THE_TMP/foo" -clipCmd "$THE_TMP/bin/command" -imodSourceScript "$THE_TMP/imod.sh" $WF

  # Check exit code, kepler is always zero even if it fails
  # which is why we have a WORKFLOW.FAILED.txt file
  [ "$status" -eq 0 ]

  # will only see this if kepler fails
  echoArray "${lines[@]}"

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  # Will be output if anything below fails
  cat "$THE_TMP/$README_TXT"
  
  # Verify we did not get a WORKFLOW.FAILED.txt file
  [ ! -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Verify we got a README.txt
  [ -s "$THE_TMP/$README_TXT" ]
  
  # Check we got a workflow.status file
  [ -s "$THE_TMP/$WORKFLOW_STATUS" ]

  # Check we got the input.mrc file
  [ -s "$THE_TMP/data/input.mrc" ]

  # Check we got mrc.info file
  [ -s "$THE_TMP/data/mrc.info" ]
}
 
