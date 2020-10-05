# Working

## Redmine internal link syntax is preserved

This is a [[wiki link]].

## Code highlighting is preserved

``` sql
SELECT * FROM table;
```

## Inline code can contains @

Repository is `git@github.com/user/repo`.

## Block code use backtick, not indent, if they are not preceded by a blank line

Try this:

```
echo "OK"
```

## Disabled strange \`\\\\www\.\`\` parsing parsing from redmine

\\\\www\.server\\asd\\asd\\index.html  
\\\\www\.server.com

## Quotations are preserved

> I'll be back! Ha! You didn't know I was gonna say that, did you?

## XML tags are preserved

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
        <array>
            <dict>
                <key>foo</key>
                <string>bar</string>
            </dict>
        </array>
    </plist>

## Plain URL should not get broken by escaped characters

http://example.com/example_site/#test

# Known limitations

## Unsupported cell formatting is dropped silently

|                         |                   |
|-------------------------|-------------------|
| one                     | two               |
| Cell spanning 2 columns |                   |
| Cell spanning 2 rows    | one               |
| two                     |                   |
| Right-aligned cell      | Left-aligned cell |

## Unsupported multiline tables

| one                                          | two |
|----------------------------------------------|-----|
| Cell spanning 2 columns<br/>asd |     |
| Cell spanning 2 rows                         | one |


| one                                                                                         | two                                                                                         |
|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| multilinecell<br/>- List 1<br/>- List 2<br/>- List 3 | multilinecell<br/>- List 1<br/>- List 2<br/>- List 3 |
| Right-aligned cell                                                                          | Left-aligned cell                                                                           |


Other Table

|     |            |
|-----|------------|
| A:  | B          |
| D:  | Dunkelgrün |
| C:  | Grün       |

## List with code block is partially supported

The numbering will be reset after each code block, but layout is preserved:

1.  first item:

``` sql
SELECT * FROM table;
```

1.  second item:

```
rm -rf /tmp/*
```

1.  final item

But some more complex case might result in broken list layout.

## Wrongly formatted lists (wrong textile, but works in redmine)

Correct List

1.  A
    -   A
        -   B
            -   C
    -   A
        -   R
2.  A
    -   G
        -   G
            -   G
                -   G
                -   G
            -   G

First wrong List

1.  A
    -   A
        -   B
            -   C
    -   A
        -   R
2.  A
    -   G
        -   G
            -   G
                -   G
                -   G
            -   G

Second wrong list

-   A
    1.  A
        1.  B
            1.  C
    2.  A
        1.  R
-   A
    1.  G
        1.  G
            1.  G
                1.  G
                2.  G
            2.  G
