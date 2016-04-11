Feature: EnoughSpace

This acceptance test verifies the existing production servers have acceptable disk space
to ensure proper execution.  If any of these tests fail then I need to take a look at that server
to see what could be wrong.  I wrote this so I don't have to ping all the boxes individually and
see if anything is starting to go south.

  Scenario Outline: Prod Server with C and D drives
    Given the server prefix <server_prefix>
    When the servers <start_server_num> through <end_server_num> disk spaces are checked
    Then the C Drive should have at least <c_drive_size> GB
    And the D Drive should have at least <d_drive_size> GB
    Examples:
    |server_prefix|start_server_num|end_server_num|c_drive_size|d_drive_size|
    |"P-PR-ADS"|6  |29 |9  |100|
    |"P-PR-TRK"|21 |40 |8  |60|
    |"P-PR-CLK"|11 |14 |20 |49|
    |"P-PR-MED"|11 |12 |12 |10|
    |"P-PR-ONP"|11 |14 |23 |40|

  Scenario Outline: Prod Server with C drive Only
    Given the server prefix <server_prefix>
    But the server has no D drive
    When the servers <start_server_num> through <end_server_num> disk spaces are checked
    Then the C Drive should have at least <c_drive_size> GB
    Examples:
    |server_prefix|start_server_num|end_server_num|c_drive_size|
    |"P-PR-CCB"|11  |12 |25|
    |"P-PR-CLT"|11  |18 |20|
    |"P-PR-VCON"|11 |12 |15|

  Scenario: Prod Util servers
    Given the server prefix "P-PR-UTL"
    When the servers "DS01,AS01,MS01,WEB03,WEB04" disk spaces are checked
    Then the C Drive should have at least 9 GB
    And the D Drive should have at least 20 GB

  Scenario: Prod ADP servers
    Given the server prefix "P-PR-ADP"
    But the server has no D drive
    When the servers "BAT11,DFA11,WEB21,WEB22,WEB23,WEB24" disk spaces are checked
    Then the C Drive should have at least 18 GB

  Scenario: Show Command line
    When the command line is processed
    Then the user name is outputted
