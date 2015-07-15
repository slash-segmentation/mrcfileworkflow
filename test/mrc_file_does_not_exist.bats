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
@test "Test where input workspacefile does not exist" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  # Write out to command.tasks file under bin directory
  # When $THE_TMP/bin/command is invoked it will read
  # from command.tasks file and execute the command
  # in it following this format: exit code,std out,std err,command to execute
  #
  # Note: the command to execute ie echo will be given all the arguments passed to the command
  #

  # Run kepler.sh
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -CWS_outputdir $THE_TMP -mrcfile "$THE_TMP/foo.mrc" $WF

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
  [ "${lines[0]}" == "simple.error.message=Input MRC File not found" ]
  [ "${lines[1]}" == "detailed.error.message=$THE_TMP/foo.mrc does not exist on filesystem" ]


  # Verify we got a README.txt
  [ -s "$THE_TMP/$README_TXT" ]
  
  # Check we got a workflow.status file
  [ -s "$THE_TMP/$WORKFLOW_STATUS" ]
 
  cat "$THE_TMP/$WORKFLOW_STATUS" 
  # Check we got done phase
  run egrep "^phase=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "phase=Start" ]

  # Check we got correct phase help
  run egrep "^phase.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "phase.help=Processing has started" ]

  # Check phase list is correct
  run egrep "^phase.list=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "phase.list=Start,Done" ]

  # Check phase list help is correct
  run egrep "^phase.list.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "phase.list.help=Denotes the various steps or phases in running the workflow" ]

  # Check estimated disk space is correct
  run egrep "^estimated.total.diskspace=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.total.diskspace=unknown" ]

  # Check estimated disk space help is correct
  run egrep "^estimated.total.diskspace.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.total.diskspace.help=Estimate of disk space consumed in bytes" ]


  # Check disk space is correct
  run egrep "^diskspace.consumed=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "diskspace.consumed=unknown" ]

  # Check disk space help is correct
  run egrep "^diskspace.consumed.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "diskspace.consumed.help=Disk space in bytes" ]

  # Check estimated walltime
  run egrep "^estimated.walltime.seconds=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.walltime.seconds=0" ]

  # Check estimated walltime help
  run egrep "^estimated.walltime.seconds.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.walltime.seconds.help=Estimated wall time the workflow will take to run" ]

  # Check estimated total cpu
  run egrep "^estimated.total.cpu.seconds=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.total.cpu.seconds=0" ]

  # Check estimated walltime help
  run egrep "^estimated.total.cpu.seconds.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "estimated.total.cpu.seconds.help=Estimated total cpu time workflow will consume" ]


  # Check cpu per cluster
  run egrep "^cpu.seconds.consumed.per.cluster.list=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "cpu.seconds.consumed.per.cluster.list=unknown:0" ]

  # Check estimated walltime help
  run egrep "^cpu.seconds.consumed.per.cluster.list.help=" "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "cpu.seconds.consumed.per.cluster.list.help=Cpu consumed by cluster" ]

}
 
