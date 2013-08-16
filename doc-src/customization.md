# Apropos

## Advanced Customization

If you want to go beyond breakpoint and resolution variants, you can use Apropos' Ruby interface to customize it for your app.

This code should go in a initializer file or in your Compass config file.

### Example: localized images

This example creates a variant that will recognize images for different languages. We assume that your app adds a class such as "lang-en" to the body to indicate the language of the page. With this code, you could have a base file "image.jpg" and variants such as "image.fr.jpg" and "image.ja.jpg" for different languages.

And of course, this works in combination with other variants, so if you're using Apropos' hidpi and breakpoints you could have files like "image.medium.2x.fr.jpg" and all the proper rules would be generated.

```ruby
# This would be in your Compass config.rb or in a Rails initializer

SUPPORTED_LANGUAGES = ['en', 'fr', 'ja']

# Use a broad regex to match the file extension...
Apropos.add_class_image_variant(/[a-z]{2}/) do |match|
  # ... but validate it against our app's supported languages
  if SUPPORTED_LANGUAGES.include? match[0]
    ".lang-#{match[0]}"
  end
end
```
