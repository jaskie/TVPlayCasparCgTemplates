# TVPlay CasparCg templates
[CasparCG](/CasparCG/server) templates for use with [TVPlay](/jaskie/PlayoutAutomation) TV play-out automation written in [FlashDevelop](http://www.flashdevelop.org/).

## SimpleCrawl
It's a template that shows crawl bar on screen. It's designed to display crawl using [CgElementsController](jaskie/PlayoutAutomation/wiki/Plugin-01.-CgElementsController) plugin of TVPlay.

The crawl is highly customizable: there are separate files for background and sentences separator. All text parameters may be set in [simplecrawl.config](/jaskie/TVPlayCasparCgTemplates/blob/master/SimpleCrawl/out/simplecrawl.config) file.

Displayed texts may be readed come from a local file or web service as well. The template reads whole text package, displays them all, and then, just before new iteration is started, reads new content. If the content source begins with `http`, a anticache parameter is added to url line.

The template is also able to display clock.
