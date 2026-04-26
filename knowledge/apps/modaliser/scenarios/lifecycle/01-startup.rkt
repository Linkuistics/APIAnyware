#lang app-spec

(scenario "lifecycle-startup"
  #:description "Impl launches, emits [lifecycle] startup and [config] loaded"
  (wait-for-log #px"\\[lifecycle\\] startup" #:timeout 10.0)
  (wait-for-log #px"\\[config\\] loaded" #:timeout 10.0))
