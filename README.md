# TVPlay CasparCg templates
[CasparCG](https://github.com/CasparCG/server) templates for use with [TVPlay](https://github.com/jaskie/PlayoutAutomation) TV play-out automation written in [FlashDevelop](http://www.flashdevelop.org/).

## SimpleCrawl
It's a template that shows crawl bar on screen. It's designed to display crawl using [CgElementsController](https://github.com/jaskie/PlayoutAutomation/wiki/Plugin-01.-CgElementsController) plugin of TVPlay.

The crawl is highly customizable: there are separate files for background and sentences separator. All text parameters may be set in [simplecrawl.config](https://github.com/jaskie/TVPlayCasparCgTemplates/blob/master/SimpleCrawl/out/simplecrawl.config) file.

Displayed texts may be readed come from a local file or web service as well. The template reads whole text package, displays them all, and then, just before new iteration is started, reads new content. If the content source begins with `http`, a anticache parameter is added to url line.

The template is also able to display clock.

Template contains only one - [Lato](http://www.latofonts.com/lato-free-fonts) - font embedded. Not embedded fonts have much lower rendering quality, so the only option is add them to /assets folder, [Main.as](https://github.com/jaskie/TVPlayCasparCgTemplates/blob/master/SimpleCrawl/src/Main.as) and recompile.
