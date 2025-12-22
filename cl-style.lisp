(in-package #:cl-style)

(defvar style-map (make-hash-table :test 'equal))

(defvar *pseudo-classes*
  '(:hover :focus :active :visited :link
    :first-child :last-child :first-of-type :last-of-type
    :nth-child :nth-of-type :only-child :only-of-type
    :disabled :enabled :checked :required :optional
    :valid :invalid :in-range :out-of-range
    :focus-within :focus-visible :target :empty))

(defvar *pseudo-elements*
  '(:before :after :first-line :first-letter :placeholder :selection))

(defun pseudo-class-p (key)
  (member key *pseudo-classes*))

(defun pseudo-element-p (key)
  (member key *pseudo-elements*))

(defun output-style-tags ()
  (loop for key being the hash-keys of style-map
        using (hash-value value)
        collect (loop for val in value
                 collect (format nil "~a " val)
                      into result
                finally (return (format nil "<style> ~{~a~} </style>" result)))))

(defun purge ()
  (setf style-map (make-hash-table :test 'equal)))

(defun handle-media-query (class-name query-modifier css)
  (loop for (key val) on (car (cdr (cadadr css))) by #'cddr
        collect (format nil "~a: ~a;" (string-downcase key) (if (symbolp val) (string-downcase val) val))
          into result
        finally (return (format nil "@media (~a: ~apx) {
                                       .~a { ~{~a~^ ~} }
                                     }"
                                (string-downcase query-modifier)
                                (caadr css)
                                class-name
                                result))))

(defun handle-pseudo (class-name pseudo css)
  (let ((separator (if (pseudo-element-p pseudo) "::" ":")))
    (loop for (key val) on css by #'cddr
          collect (format nil "~a: ~a;" (string-downcase key) (if (symbolp val) (string-downcase val) val))
            into result
          finally (return (format nil ".~a~a~a { ~{~a~^ ~} }"
                                  class-name
                                  separator
                                  (string-downcase pseudo)
                                  result)))))

(defun handle-non-media-query (class-name css)
  (loop for (key . val) in css
        collect (format nil "~a: ~a;" (string-downcase key) (if (symbolp val) (string-downcase val) val))
          into result
        finally (return (format nil ".~a { ~{~a~^ ~} }" class-name result))))

(defmacro defstyle (name styles)
  (let ((class-name (format nil "cl-style-~A" (sxhash (princ-to-string styles))))
        (non-media-css '())
        (all-css '()))
    (loop for (key val) on styles by #'cddr
          if (or (eql :max-width key)
                 (eql :min-width key))
            do (push (handle-media-query class-name key val) all-css)
          else if (or (pseudo-class-p key)
                      (pseudo-element-p key))
            do (push (handle-pseudo class-name key val) all-css)
          else
            do (push `(,key . ,val) non-media-css))
    (push (handle-non-media-query class-name non-media-css) all-css)
    (setf (gethash class-name style-map) all-css)
    `(defvar ,name
       '(:class ,class-name))))
