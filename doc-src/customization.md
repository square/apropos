# Apropos

## Advanced Customization

If you want to go beyond breakpoint and resolution variants, you can use Apropos' Ruby interface to customize it for your app.

Your customization code should go in a initializer file or in your Compass config file.

### Example: localized images

This example creates a variant that will recognize images for different languages. We assume that your app adds a class such as "lang-en" to the body to indicate the language of the page. With this code, you could have a base file "image.jpg" and variants such as "image.fr.jpg" and "image.ja.jpg" for different languages.

And of course, this works in combination with other variants, so if you're using Apropos' hidpi and breakpoints you could have files like "image.medium.2x.fr.jpg" and all the proper rules would be generated.

```ruby
# This would be in your Compass config.rb or in a Rails initializer.
# You may need to add `require 'apropos'` depending on load order in your app.

SUPPORTED_LANGUAGES = ['en', 'fr', 'ja']

# Use a broad regex to match the file extension...
Apropos.add_class_image_variant(/^[a-z]{2}$/) do |match|
  # ... but validate it against our app's supported languages
  if SUPPORTED_LANGUAGES.include? match[0]
    ".lang-#{match[0]}"
  end
end
```

### Example: country + language

Here's a more complex example where we recognize simple locale identifiers that encode country as well as language. We also recognize just the language code, or just the country code. This means you could have images like "image.ca.jpg", "image.fr-ca.jpg", "image.fr.jpg", etc...

```ruby
SUPPORTED_COUNTRIES = ['us', 'ca', 'fr']
SUPPORTED_LANGUAGES = ['en', 'fr']

Apropos.add_class_image_variant(/^([a-z]{2})(-[a-z]{2})?$/) do |match|
  lang_or_country = match[1]
  # Strip off the dash
  country = match[2][1..-1] if match[2]
  if country
    if SUPPORTED_COUNTRIES.include?(country) && SUPPORTED_LANGUAGES.include?(lang_or_country)
      # Return a class like ".locale-fr-ca"
      ".locale-#{lang_or_country}-#{country}"
    end
  else
    # Determine if the two-letter code is a country, language, or both (like "fr")
    classes = []
    classes << ".lang-#{lang_or_country}" if SUPPORTED_LANGUAGES.include? lang_or_country
    classes << ".country-#{lang_or_country}" if SUPPORTED_COUNTRIES.include? lang_or_country
    # Return nil if the code is not a supported language or country
    classes unless classes.empty?
  end
end
```
