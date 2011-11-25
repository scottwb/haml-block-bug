Repro For Haml Block Bug
========================

This is a simple Rails app that demonstrates an inconsistency in the Haml parser between the
`development` and `production` environments, exhibiting what I believe is a bug in the production environment.

_**UPDATE:** I've now had third-party reports of this example app demonstrating the bug only when
`Haml::Template.options[:ugly]` is set to `true`, regardless of what environment is being used.
[See Haml Issue #462.](https://github.com/nex3/haml/issues/462)_

Using the included Gemfile and RVM, the results of this demonstration have been confirmed on:

  * ruby-1.8.7.p334
  * ree-1.8.7-2011.03
  * ruby-1.9.2-p180

Using the following servers:

  * WEBrick
  * Unicorn 3.6.2

Under the following versions of Rails:

  * Rails 3.0.7
  * Rails 3.0.9

Using the following versions of the Haml gem:

  * Haml 3.1.1
  * Haml 3.1.2
  * Haml 3.1.3 _(Independently verified by by [@urbanautomaton](https://github.com/urbanautomaton) - I have not confirmed)_


Running The Test
================

Run the server:
```
rails server
```

Load `http://localhost:3000` in your browser. You should see two sections: "Using pass_thru_bad" and "Using pass_thru_good".

Now, stop your server and run it in production mode with:
```
RAILS_ENV=production rails server
```

Then load `http://localhost:3000`. This time you will see the "Using pass_thru_bad" section erroneously repeated twice.


What's Going On
===============

The Haml view being displayed look like this:

```haml
%h1 Using pass_thru_bad
- pass_thru_bad do
  = "The time is #{Time.now}"

%hr

%h2 Using pass_thru_good
- pass_thru_good do
  = "The time is #{Time.now}"
```

The `pass_thru_bad` and `pass_thru_good` helpers are each simple helpers designed to just pass through the given Haml block. These are defined as:

```ruby
module ApplicationHelper
  def pass_thru_bad(&block)
    yield
  end

  def pass_thru_good(&block)
    haml_concat(capture_haml(&block))
  end
end
```

The `pass_thru_bad` helper simply yields the given block. It seems that, only in production mode, it is being given a bad block that includes the outer block it is a part of, not the inner block as intended.

