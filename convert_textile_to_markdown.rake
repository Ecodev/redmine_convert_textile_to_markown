task :convert_textile_to_markdown => :environment do
  convert = {
    Comment =>  [:comments],
    WikiContent => [:text],
    Issue =>  [:description],
    Message => [:content],
    News => [:description],
    Document => [:description],
    Project => [:description],
    Journal => [:notes],
  }

  count_success = 0
  count_failure = 0
  print 'WelcomeText'
  textile = Setting.welcome_text
  if textile != nil
    markdown = convert_textile_to_markdown(textile, "welcome-text")
    Setting.welcome_text = markdown
  end
  count_success += 1
  print '.'
  puts

  convert.each do |the_class, attributes|
    print the_class.name
    the_class.find_each do |model|
      begin
        # We may encounter errors when saving the new value.
        # For example, if it exceeds the maximum size allowed by SQL column
        attributes.each do |attribute|
          textile = model[attribute]
          if textile != nil
            markdown = convert_textile_to_markdown(textile, "#{the_class}-#{model.id}")
            model.update_column(attribute, markdown)
          end
        end
      rescue
        count_failure += 1
        puts
        puts "Conversion failed for #{the_class} with id #{model.id}"
      else
        count_success += 1
        print '.'
      end
    end
    puts
  end
  puts "Done converting #{count_success} models"
  puts "Failed converting #{count_failure} models"
end

def convert_textile_to_markdown(textile, what)
  require 'tempfile'

  # Redmine support @ inside inline code marked with @ (such as "@git@github.com@"), but not pandoc.
  # So we inject a placeholder that will be replaced later on with a real backtick.
  tag_code = 'pandoc-unescaped-single-backtick'
  textile.gsub!(/@([\S]+@[\S]+)@/, tag_code + '\\1' + tag_code)

  # Drop table colspan/rowspan notation ("|\2." or "|/2.") because pandoc does not support it
  # See https://github.com/jgm/pandoc/issues/22
  textile.gsub!(/\|[\/\\]\d\. /, '| ')

  # Drop table alignement notation ("|>." or "|<." or "|=.") because pandoc does not support it
  # See https://github.com/jgm/pandoc/issues/22
  textile.gsub!(/\|[<>=]\. /, '| ')

  # Move the class from <code> to <pre> so pandoc can generate a code block with correct language
  textile.gsub!(/(<pre)(><code)( +class="[^"]*")(>)/, '\\1\\3\\2\\4')

  # Remove the <code> directly inside <pre>, because pandoc would incorrectly preserve it
  textile.gsub!(/(<pre[^>]*>) *<code>/, '\\1')
  textile.gsub!(/<\/code> *(<\/pre>)/, '\\1')

  # Inject a class in all <pre> that do not have a blank line before them
  # This is to force pandoc to use fenced code block (```) otherwise it would
  # use indented code block and would very likely need to insert an empty HTML
  # comment "<!-- -->" (see http://pandoc.org/README.html#ending-a-list)
  # which are unfortunately not supported by Redmine (see http://www.redmine.org/issues/20497)
  tag_fenced_code_block = 'force-pandoc-to-ouput-fenced-code-block'
  textile.gsub!(/([^\n]<pre)(>)/, "\\1 class=\"#{tag_fenced_code_block}\"\\2")

  # Force <pre> to have a blank line before them
  # Without this fix, a list of items containing <pre> would not be interpreted as a list at all.
  textile.gsub!(/([^\n])(<pre)/, "\\1\n\n\\2")

  # Wrong textile input in lists
  #    # List item 1
  #    #* Subitem 1
  textile.gsub!(/^( *)[#](\*+)( +)/, "\\1*\\2\\3")
  textile.gsub!(/^( *)[\*](#+)( +)/, "\\1#\\2\\3")

  src = Tempfile.new('src')
  src.write(textile)
  src.close
  dst = Tempfile.new('dst')
  dst.close

  # gfm dropped backtick_code_block extension
  # https://github.com/jgm/pandoc/commit/3a22fbd11bba805140b1963a583a11b4fa1169a2
  command = [
    'pandoc',
    '--eol=lf',
    '--atx-headers',
    '--wrap=preserve',
    '-f',
    'textile',
    '-t',
    'markdown_github+smart',
    src.path,
    '-o',
    dst.path,
  ]
  system(*command, :out => $stdout) or raise 'pandoc failed'

  dst.open
  markdown = dst.read

  # Remove the \ pandoc puts before * and > at begining of lines
  markdown.gsub!(/^((\\[*>])+)/) { $1.gsub("\\", "") }

  # Add a blank line before lists
  markdown.gsub!(/^([^*].*)\n\*/, "\\1\n\n*")

  # Remove the injected tag
  markdown.gsub!(' ' + tag_fenced_code_block, '')

  # Replace placeholder with real backtick
  markdown.gsub!(tag_code, '`')

  # Un-escape Redmine link syntax to wiki pages
  markdown.gsub!('\[\[', '[[')
  markdown.gsub!('\]\]', ']]')

  # Un-escape Redmine quotation mark "> " that pandoc is not aware of
  markdown.gsub!(/(^|\n)&gt; /, "\n> ")

  # Remove <!-- end list --> injected by pandoc because Redmine incorrectly
  # does not supported HTML comments: http://www.redmine.org/issues/20497
  markdown.gsub!(/\n\n<!-- end list -->\n/, "\n")

  # Unescape URL that could easily get mangled
  markdown.gsub!(/(https?:\/\/\S+)/) { |link| link.gsub(/\\([_#])/, "\\1") }

  # Match all textile tables and then replace line breaks in cells with <br> tags
  # [untested]
  # markdown.gsub!(/^\|.*\|/m) {
  #   |table| table.gsub(/\|([^|]+\n?)*(?=|)/, "\\1") { |cell| cell.replace("\n", "<br />") }
  # }

  # Remove strange .www parsing
  markdown.gsub!(/(\\\\)www\./, "\\1www\\.")

  if markdown.include?("<table")
    puts "WARNING: HTML table content in #{what}"
    # Replace line breaks in html tables with tags and convert again -> pandoc should then
    # output a pipe table
    markdown.gsub!(/<table>.*?<\/table>/m) {
      |m|
      m.gsub!(/<br *\/> *\n/, ":::TAGLINEBREAK:::")


      src = Tempfile.new('src')
      src.write(m)
      src.close
      dst = Tempfile.new('dst')
      dst.close

      # gfm dropped backtick_code_block extension
      # https://github.com/jgm/pandoc/commit/3a22fbd11bba805140b1963a583a11b4fa1169a2
      command = [
        'pandoc',
        '--eol=lf',
        '--wrap=preserve',
        '-f',
        'html',
        '-t',
        'markdown_github+smart',
        src.path,
        '-o',
        dst.path,
      ]
      system(*command, :out => $stdout) or raise 'pandoc failed'

      dst.open
      m.replace(dst.read)

      m.gsub!(/:::TAGLINEBREAK:::/, "<br/>")
      m
    }
  end

  return markdown
end

