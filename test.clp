;; ***********************************************************************
;; OCC Emotion Computation TEST
;;
;; (c) 2009 Michael Kipp, DFKI
;; E-Mail: mich.kipp@googlemail.com
;; ***********************************************************************

(printout t "*** OCC TEST ***" crlf)

(clear) 
(batch occ.clp)

;; ********* INITIAL FACTS

(deffacts init 
	  "Test facts for all emotion types"
	  (personality (optimistic 0) (choleric 0) (extravert -.5) (social 0) (neurotic -.2))
	  (simple-event (id broke-my-leg) (desire -1))
	  (simple-event (id lost-my-purse) (desire -.6))
	  (simple-event (id nice-weather) (desire .3))
	  (action (id gave-ice-cream) (is-self 1) (praise .8))
	  (action (id shot-the-sheriff) (is-self 1) (praise -1))
	  (action (id punched-me) (is-self 0) (praise -.95))
	  (action (id hugged-me) (is-self 0) (praise .1))
	  (object (id nice) (appeal .6))
	  (object (id ugly) (appeal -.8))
	  (complex-event (id fail-exam) (desire -.3) (realization 0)
	  	 	 (likelihood .8))
	  (complex-event (id win-lottery) (desire 1) (realization 0)
	  	 	 (likelihood .2))
	  (complex-event (id won-lottery) (desire 1) (realization 1) (is-future no)
	  	 	 (has-occured yes) (likelihood .2) (effort .5))
	  (complex-event (id become-president) (desire .9) (realization .1) (is-future no)
	  	 	 (has-occured no) (likelihood .01) (effort .6))
	  (complex-event (id become-vice-president) (desire .9) (realization 0) (is-future no)
	  	 	 (has-occured no) (likelihood .9) (effort .8))
	  (complex-event (id run-over-by-car) (desire -1) (is-future no)
	  	 	 (has-occured no) (likelihood .9))
	  (complex-event (id lost-wallet) (desire -.6) (is-future no)
	  	 	 (has-occured yes) (realization 1))
	  (complex-event (id lost-money) (desire -.6) (is-future no)
	  	 	 (has-occured yes) (realization .3))
)

;; ********* RUN

(reset)
(printout t "+++ BEFORE" crlf)
(facts)
(run)

(printout t "+++ AFTER" crlf)
(facts)
