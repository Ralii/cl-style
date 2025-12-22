(asdf:defsystem #:cl-style
  :description "Common lisp styles"
  :homepage "https://github.com/ralii/cl-style"
  :author "Lari Saukkonen"
  :license  "MIT"
  :pathname #.*default-pathname-defaults*
  :version "0.0.1"
  :serial t
  :build-operation program-op
  :build-pathname "cl-style"
  :entry-point "CL-STYLE::MAIN"
  :components ((:file "package")
               (:file "cl-style")))

