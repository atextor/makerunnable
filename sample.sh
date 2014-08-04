#!/bin/bash

# Create a Java class
cat <<- EOF > Test.java
	package de.atextor.test;

	public class Test {
		public static void main(String[] args) {
			System.out.println("Hello World");
		}
	}
EOF

# Create a manifest
cat <<- EOF > MANIFEST.MF
Main-Class: de.atextor.test.Test

EOF

# Compile the class, and jar class file and manifest
mkdir classes
javac -d classes Test.java
jar cvfm test.jar MANIFEST.MF -C classes/ .

# Run makerunnable on jar
./makerunnable.sh -o test.sh test.jar

# Remove all intermediary files
rm -rf Test.java MANIFEST.MF classes test.jar

echo Now run ./test.sh
