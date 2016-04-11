Feature: Server Connections Work

This acceptance test verifies the DC3 connections can be established and removed.
These features must be run with user and password passed as command line arguments.

  Scenario: Can Connect to DC3 Server
    Given a server prefix "P-PR-ADS"
    And a server list of "WEB06"
    When the server connect is performed
    Then the status should be connected

  Scenario: Can Disconnect to DC3 Server
    Given a server prefix "P-PR-ADS"
    And a connected server list of "WEB06"
    When the server disconnect server is performed
    Then the status should be disconnected
