# Redmine converter from Textile to Markown [![Build Status](https://travis-ci.com/Ecodev/redmine_convert_textile_to_markown.svg?branch=master)](https://travis-ci.com/Ecodev/redmine_convert_textile_to_markown)

This is a rake task for [Redmine](http://www.redmine.org/) that uses [pandoc](http://pandoc.org/) to convert database content from Textile to Markdown formatting. The conversion is tweaked to adapt to Redmine's special features.

### Known limitations

Because Redmine's textile is different than pandoc's textile, and because of
some limitation in pandoc, the result will not be perfect, but it should be good
enough to get you started. Here are some known limitations:

* Numbered lists containing `<pre>` blocks will lose their numbering (restarting at 1 after the `<pre>`). Some complex cases will lose their list layout entirely.
* Tables without proper headers will be rendered with an empty header
* Some [interlaced formatting of inline code and bold will be messed up](https://github.com/jgm/pandoc/issues/3024)
* `<!-- -->` may appear in final ouput in a few places because Redmine incorrectly [does not support HTML in markdown](http://www.redmine.org/issues/20497)

## Usage

1. Backup your database
2. [Install pandoc](http://pandoc.org/installing.html)
3. Install the task:

    ```sh
    cd $REDMINE_ROOT_DIRECTORY
    wget -P lib/tasks/ https://github.com/Ecodev/redmine_convert_textile_to_markown/raw/master/convert_textile_to_markdown.rake
    ```

4. Run the task:

    ```sh
    bundle exec rake convert_textile_to_markdown RAILS_ENV=production
    ```

## History

This script was built upon @sigmike [answer on Stack Overflow](http://stackoverflow.com/a/19876009), later [slightly modified by Hugues C.](http://www.redmine.org/issues/22005) and finally significantly completed by us.
