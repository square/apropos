# Apropos

Apropos simplifies and automates the task of using multiple versions of an image in responsive and/or localized web sites. Instead of manually writing a lot of CSS rules to swap different images, Apropos generates CSS for you based on a simple file naming convention.

## Installation

Add this line to your application's Gemfile:

    gem 'apropos'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apropos

## Usage

Apropos depends on [Compass](http://compass-style.org/), so make sure you have that installed and configured in your project first.

### Configure variants

You can configure what variants will be recognized in your project. There are helpers for configuration in both Ruby and Sass. Here is a sample Ruby configuration that will recognize high-dpi variants and variants for a few breakpoints:

    # Put this in your Compass config.rb file or in a Rails initializer

    dpi_query = '(-webkit-min-device-pixel-ratio: 1.75), (min-resolution: 168dpi)'
    medium_query = '(min-width: 768px)'
    large_query = '(min-width: 1024px)'

    Apropos.add_dpi_image_variant('2x', dpi_query)
    Apropos.add_breakpoint_image_variant('medium', medium_query)
    Apropos.add_breakpoint_image_variant('large', large_query)

### Use Apropos in Sass

With the above configuration, you can now use Apropos in your Sass file:

    // Put this in a .sass or .scss file, such as application.css.sass
    @import apropos

    .hero
      // Use hero.jpg as the background of this element, and load any image
      // variants that exist. If you use $generate-height: true, the function
      // will also generate height definitions based on the height of each
      // image (except dpi variants, since you want to display those at the
      // original dimensions).
      +apropos-bg-variants('hero.jpg', $generate-height: true)

### Name image files

With the configuration and Sass set up, you can now include any set of variants on your image with a simple file naming convention:

    # File listing e.g. app/assets/images:
    hero.jpg
    hero.medium.jpg
    hero.large.jpg
    hero.2x.jpg
    hero.2x.medium.jpg
    hero.2x.large.jpg

In this example, `hero.jpg` would be your base image, most likely a mobile version. `hero.medium.jpg` would be swapped in at the 768px breakpoint, and `hero.large.jpg` would be swapped in at 1024px. On a high-dpi device, `hero.2x.jpg`, `hero.2x.medium.jpg`, and `hero.2x.large.jpg` would be used instead.

## Why use Apropos?

There are many tools and techniques for using responsive images. What makes Apropos different? A few key principles:

- Let the browser do what it does best. CSS rules are more efficient and reliable than a solution that relies on Javascript or setting cookies for each visitor.
- Avoid duplicate downloads. Almost all Javascript solutions produce unnecessary extra downloads, which CSS classes and media queries avoid.
- No server logic should be required. Rather than setting a cookie and serving up different assets based on the cookie, we should be able to push compiled CSS and images to a CDN and rely on the browser to request the right images.
- Take advantage of the "metadata" encoded in file names. We need to create separate assets for high-dpi devices, breakpoints, locales, etc anyway. We can lean on the filesystem with a simple naming convention rather than hand-coding a bunch of CSS.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

© 2013 Square, Inc.
