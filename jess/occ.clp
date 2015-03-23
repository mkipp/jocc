;; ***********************************************************************
;; OCC Emotion Computation
;;
;; EMOTION TYPES:
;; Currently modelled emotions (14) are
;;
;; - Well-Being:     JOY, DISTRESS
;; - Prospect-Based: HOPE, FEAR, SATISFACTION, RELIEF, DISAPPOINTMENT, 
;;   		     FEARS-CONFIRMED
;; - Attribution:    PRIDE, SHAME, ADMIRATION, REPROACH
;; - Attraction:     LOVE, HATE
;;
;;
;; PERSONALITY:
;; Currently, personality is modelled globally with a single fact
;;
;; (c) 2009 Michael Kipp
;; E-Mail: michael.kipp@hs-augsburg.de
;; ***********************************************************************

;; ********* DATA STRUCTURES

(deftemplate eec 
	     "Emotion-eliciting condition"
	     (slot id))

(deftemplate event extends eec
	     "Emotion-eliciting event"
	     (slot desire (type FLOAT))
)

(deftemplate simple-event extends event)

;; note that for disappointment you need an event that occured
;; and had a certain degree of realization; therefore, you 
;; cannot use realization instead of has-occured
;; reason for having both is-future and has-occured:
;; it is possible that an event *could* have occured but did not
;; (=> is-future FALSE and has-occured FALSE)

(deftemplate complex-event extends event
	     "Prospect-based event"
	     (slot has-occured (type ATOM) (default no))
	     (slot is-future (type ATOM) (default yes))
	     (slot likelihood (type FLOAT) (default 1))
	     (slot effort (type FLOAT) (default 0))
	     (slot realization (type FLOAT) (default 1))
)

(deftemplate action extends eec
	     "Emotion-eliciting action"
	     (slot praise (type FLOAT))
	     (slot is-self (type NUMBER) (default 0))
)

(deftemplate object extends eec
	     "Emotion-eliciting person or object"
	     (slot appeal (type FLOAT))
	     (slot familiarity (type FLOAT) (default .5))
)

(deftemplate emotion 
	     "Emotion resulting from an EEC"
	     (slot type) 
	     (slot intense (type FLOAT)) 
	     (slot cause))

(deftemplate personality
	     "Personality profile with aspects relevant to OCC processing. All values between -1 and +1."
	     (slot optimistic (type FLOAT) (default 0))
	     (slot choleric (type FLOAT) (default 0))
	     (slot extravert (type FLOAT) (default 0))
	     (slot neurotic (type FLOAT) (default 0))
	     (slot social (type FLOAT) (default 0))
)

;; ********* FUNCTIONS

;; use this whenever values are multiplied

(deffunction mylog (?x) 
	     "Maps number from [0,1] to [0,1] with log warp."
	     (return (- (log10 (+ 10 (* ?x 90))) 1)))

(deffunction joy-function (?desire ?extraversion)
	     "depends on extraversion"
	     ;; have to use 1.0 here!
	     (return (max 0 (min 1.0 (* (** 2 ?extraversion) ?desire)))))

(deffunction distress-function (?desire ?neurotic)
	     "depends on neuroticism, expects negative desire"
	     ;; have to use 1.0 here!
	     (return (max 0 (min 1.0 (* (** 2 ?neurotic) (abs ?desire))))))


;; ********* RULES: WELL-BEING EMOTIONS


(defrule joy
	 "Something happened that I wanted to happen."
	 (simple-event (id ?id) (desire ?d&:(> ?d 0)))
	 (personality (extravert ?extra))
	 =>
	 (assert (emotion (type JOY) 
	 	 	  (intense (joy-function ?d ?extra))
			  (cause ?id))))

(defrule distress
	 "Something happened that I did not want to happen."
	 (simple-event (id ?id) (desire ?d&:(< ?d 0)))
	 (personality (neurotic ?neurotic))
	 =>
	 (assert (emotion (type DISTRESS) 
	 	 	  (intense (distress-function ?d ?neurotic))
			  (cause ?id))))

;; ********* RULES: PROSPECT-BASED EMOTIONS

(defrule hope
	 "Something may happen that I really want to occur."
	 (complex-event (id ?id) (desire ?d&:(> ?d 0)) 
	 		    	 (is-future ?f&:(eq ?f yes))
	 		    	 (has-occured ?ho&:(eq ?ho no))
				 (likelihood ?li))
	 =>
	 (assert (emotion (type HOPE) 
	 	 	  (intense (* ?d (mylog ?li)))
			  (cause ?id))))

(defrule fear
	 "Something may happen that I wish to never occur."
	 (complex-event (id ?id) 
	 	       	(desire ?d&:(< ?d 0)) 
	 		(is-future ?f&:(eq ?f yes))
	 		(has-occured ?ho&:(eq ?ho no))
		       	(likelihood ?li))
	 =>
	 (assert (emotion (type FEAR) 
	 	 	  (intense (* (abs ?d) (mylog ?li)))
			  (cause ?id))))

(defrule satisfaction
	 "Something happened that I really wanted to occur."
	 (complex-event (id ?id) 
	 		(desire ?d&:(> ?d 0)) 
	 		(is-future ?f&:(eq ?f no))
	 		(has-occured ?ho&:(eq ?ho yes))
	 	       	(realization ?r)
		       	(effort ?eff))
	 =>
	 (assert (emotion (type SATISFACTION) 
	 	 	  (intense (* ?d (mylog ?r) (mylog ?eff)))
			  (cause ?id))))

(defrule disappointment
	 "Something did not happen that I really wanted to occur."
	 (complex-event (id ?id) 
	 	       	(desire ?d&:(> ?d 0)) 
	 		(is-future ?f&:(eq ?f no))
	 		(has-occured ?ho&:(eq ?ho no))
	 	       	(realization ?r)
			(likelihood ?l)
		       	(effort ?eff))
	 =>
	 (assert (emotion (type DISAPPOINTMENT) 
	 	 	  (intense (* (mylog ?l) (- 1 (* ?d (mylog ?r) (mylog ?eff)))))
			  (cause ?id))))

(defrule relief
	 "Something bad did not happen."
	 (complex-event (id ?id) 
	 	       	(desire ?d&:(< ?d 0)) 
	 		(is-future ?f&:(eq ?f no))
	 		(has-occured ?ho&:(eq ?ho no))
	 	       	(likelihood ?l))
	 =>
	 (assert (emotion (type RELIEF) 
	 	 	  (intense (* (abs ?d) (mylog ?l)))
			  (cause ?id))))

(defrule fears-confirmed
	 "Something bad did actually happen."
	 (complex-event (id ?id) 
	 	       	(desire ?d&:(< ?d 0)) 
	 		(is-future ?f&:(eq ?f no))
	 		(has-occured ?ho&:(eq ?ho yes))
	 	       	(realization ?r))
	 =>
	 (assert (emotion (type FEARS-CONFIRMED) 
	 	 	  (intense (* (abs ?d) (mylog ?r)))
			  (cause ?id))))

;; ********* RULES: ATTRIBUTION EMOTIONS

(defrule pride
	 "I did something nice."
	 (action (id ?id) (praise ?p&:(> ?p 0)) (is-self ?s&:(= ?s 1)))
	 =>
	 (assert (emotion (type PRIDE)
	 	 	  (intense ?p)
			  (cause ?id))))

(defrule shame
	 "I did something nasty."
	 (action (id ?id) (praise ?p&:(< ?p 0)) (is-self ?s&:(= ?s 1)))
	 =>
	 (assert (emotion (type SHAME)
	 	 	  (intense (abs ?p))
			  (cause ?id))))

(defrule admiration
	 "Someeone else did something nice."
	 (action (id ?id) (praise ?p&:(> ?p 0)) (is-self ?s&:(= ?s 0)))
	 =>
	 (assert (emotion (type ADMIRATION)
	 	 	  (intense ?p)
			  (cause ?id))))

(defrule reproach
	 "Someeone else did something nasty."
	 (action (id ?id) (praise ?p&:(< ?p 0)) (is-self ?s&:(= ?s 0)))
	 =>
	 (assert (emotion (type REPROACH)
	 	 	  (intense (abs ?p))
			  (cause ?id))))


;; ********* RULES: ATTRACTION EMOTIONS

(defrule love
	 (object (id ?id) (appeal ?a&:(> ?a 0)) (familiarity ?f))
	 =>
	 (assert (emotion (type LOVE)
	 	 	  (intense (* ?a (mylog ?f)))
			  (cause ?id))))

(defrule hate
	 (object (id ?id) (appeal ?a&:(< ?a 0)) (familiarity ?f))
	 =>
	 (assert (emotion (type HATE)
	 	 	  (intense (* (abs ?a) (mylog ?f)))
			  (cause ?id))))


