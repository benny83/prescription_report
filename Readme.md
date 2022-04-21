# Prescription Report

This repository is implements the report generation of filled prescriptions and income according to the input data.

[Formulation of the problem](https://gist.github.com/schneiderderek/a9c0a8b29bcd51f43c9fc198c6c13ece)

Ruby version used 3.1.0

## Getting started

Clone this repo, go to the project folder, run `bundle install` and then `./generate_report.rb {path_to_file}` (or also `ruby generate_report.rb {path_to_file}`).

If you want to see detailed info, add `-d` (`--details`) flag, for example `./generate_report.rb public/sample.txt --details`.


## Developer comment:

Any code can fit in one line - this code will work, but it will be completely unreadable. The original working version of this code was written in 12 lines, which was readable to me. Nevertheless, my personal policy is this - no matter how many lines the code takes, the main thing is that absolutely everyone can understand it (definitely we are talking about developers). Therefore, every time I write code, I imagine myself in the place of a junior who will understand what is written there.

There was an idea to break this functionality into small classes / modules, but I considered this option to be rather redundant for current task and decided to limit myself to a service that generates the necessary report.
The choice of algorithm was made in favor of filtering and grouping in order to be able to easily debug and expand the logic - at each stage, you can easily modify or fix something.

The current algorithm can be described as:

1) Initialization of objects - *@file*, *@filtered_data* and the *@report* itself
2) We parse and transfer the data into a convenient format - `:fetch_by_patient_and_drug` method returns an array e.g.:
```ruby
[{ "Nick A" => "created" }, ...]
```
3) Then combine objects with the same keys - we get a hash where the key is the patient and his medicine (for example, `"Nick A"` or `"John E"`), and the value is a list of all events ( `["created", "filled", "returned", ...]`). All data at this stage will be stored in `@filtered_data`.

Note: the usual `:merge` is not suitable, because as a result the value can contain both a string (if there is only one event) or an array of events.

With a mass merge, if there is no conflict, the value skips the logic from the passed block, but you can use `:transform_values!` afterwards:

```ruby
    filtered_data.merge!(*grouped_data) { |_, prev, val| Array(prev) << val }
    filtered_data.transform_values! { |e| Array(e) }
```

4) Skipping invalid records (`:skip_incomplete_data`) - those that are *filled* or *returned* before creation. Patients who *filled*/*returned*, but didnt't *create* the prescription, will also be skipped from the final report.
Sample data at this stage:
```ruby
{ "Nick" => [], "Mark" => ["filled", "returned", "filled", "filled"], "John" => ["filled", "returned"] }
```
5) Counting fills and income - `:render_report` will calculate and save the result as an array in `@report`, which can then be output to the console.


Description above only reveals the details of the code, and also possibly answers questions that may arise e.g., "Why was this filtering used and not another?" or "Why was this method used and not another?". However, if you look at the core of the project (service), you can immediately tell what it does, what objects are used and what methods are called on them.

Looking at the tests, you can see that the logic is the same and simple, but if you look at the files in the `support/` folder that we are checking, you can think about what happens if the file is empty or consists of only fillings and returns. By the way thanks to the last test I found a bug in the final version of my code, which prompted me to rewrite the `:merge_events` method - and this is another strong proof of how cool and useful tests are.
