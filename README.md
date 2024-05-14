# Résumé/CV for Jesse Brault

**NOTE**: if you would like a copy of the résumé in PDF form, please message me.

To make creating variations of my résumé/cv easier, I created a simple ruby program. The output is a pdf using `asciidoctor-pdf`. 

To build from the source, simply run `./resume build` from the root directory. Pre-requisites:
* `ruby` and `bundler` are installed
* run `bundler install`

There are two possible commands: `./resume build` and `./resume create`. The first generates the necessary files,
builds them, and can additionally open the built resume in Preview (Mac OS only). The latter generates only
the necessary files, as well as a shell script `./build` in the build directory which can be used to build the file. This allows for customization of the asciidoc file before building it.

Use `./build help` or `./build help <command>` for more information about CLI options for each command.
