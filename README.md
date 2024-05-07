# Résumé/CV for Jesse Brault

**NOTE**: if you would like a copy of the résumé in PDF form, please message me.

To make creating variations of my résumé/cv easier, I created a simple ruby program. The output is a pdf using `asciidoctor-pdf`. 

To build from the source, simply run `./resume` from the root directory. Pre-requisites:
* `ruby` and `bundler` are installed
* run `bundler install`

Command-line options for `./resume`:
* `--job_title`: defaults to `Full-Stack Software Engineer`.
* `--jvm`: emphasize JVM languages/projects (default).
* `--web`: emphasize web languages/projects.
* `--page_size`: defaults to `a4`.
* `--open`: automatically open the built PDF in the Preview app (Mac OS only).
