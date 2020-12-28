# Unmaintained

This project was archived in December 2020. It will keep working for a while. But in the future it will require adaptations for future versions of Redmine and Pandoc. When the time comes, I suggest you to fork this project.

# Redmine converter from Textile to Markown [![Build Status](https://travis-ci.com/Ecodev/redmine_convert_textile_to_markown.svg?branch=master)](https://travis-ci.com/Ecodev/redmine_convert_textile_to_markown)

This is a rake task for [Redmine](http://www.redmine.org/) that uses [pandoc](http://pandoc.org/) to convert database content from Textile to Markdown formatting. The conversion is tweaked to adapt to Redmine's special features.

### Known limitations

Because Redmine's textile is different than pandoc's textile, and because of
some limitation in pandoc, the result will not be perfect, but it should be good
enough to get you started. Here are some known limitations:

* Numbered lists containing `<pre>` blocks will lose their numbering (restarting at 1 after the `<pre>`). Some complex cases will lose their list layout entirely.
* Tables without proper headers will be rendered with an empty header
* Multilines tables will in the first pandoc run converted mostly to HTML which we detect and then in a second might end up as proper markdown tables (if it doesn't work it stays a HTML table) by removing the `<br/>` and afterwards introducing them again into the markdown.
* Some [interlaced formatting of inline code and bold will be messed up](https://github.com/jgm/pandoc/issues/3024)
* `<!-- -->` may appear in final ouput in a few places because Redmine incorrectly [does not support HTML in markdown](http://www.redmine.org/issues/20497)

## Usage

1. Backup your database
2. [Install pandoc](http://pandoc.org/installing.html).
   See the example script `setup.sh` and adapt it to your environment for preparing the conversion.
3. Install the task:

    ```sh
    cd $REDMINE_ROOT_DIRECTORY
    wget -P lib/tasks/ https://github.com/Ecodev/redmine_convert_textile_to_markown/raw/master/convert_textile_to_markdown.rake
    ```

4. Run the task:

    ```sh
    bundle exec rake convert_textile_to_markdown RAILS_ENV=production
    ```

5. Check if you have strangely converted HTML or Markdown Tables -> There might be false positives.

   ```sh
   cd $REDMINE_ROOT_DIRECTORY
   wget -P lib/tasks/ https://github.com/Ecodev/count_tables/raw/master/convert_textile_to_markdown.rake
   bundle exec rake count_tables RAILS_ENV=production
   ```

   This will output all content into files in the current working dir where HTML or markdown tables have been detected to counter check.

## Testing

Run the tests with

```sh
ruby test.rb
```

## History

This script was built upon @sigmike [answer on Stack Overflow](http://stackoverflow.com/a/19876009), later [slightly modified by Hugues C.](http://www.redmine.org/issues/22005) and finally significantly completed by us.
