# PJ API

[![Build Status](https://travis-ci.org/ushis/pj-api.svg?branch=master)](https://travis-ci.org/ushis/pj-api)
[![Dependency Status](https://gemnasium.com/badges/github.com/ushis/pj-api.svg)](https://gemnasium.com/github.com/ushis/pj-api)
[![Coverage Status](https://coveralls.io/repos/github/ushis/pj-api/badge.svg?branch=master)](https://coveralls.io/github/ushis/pj-api?branch=master)
[![codebeat badge](https://codebeat.co/badges/8c15d130-6c34-4c39-9315-d931d210c779)](https://codebeat.co/projects/github-com-ushis-pj-api)

The API behind https://pj.honkgong.info helps you to organize your car
sharing group.

## Development

Clone the repo:

```
git clone https://github.com/ushis/pj-api.git
cd pj-api
```

Setup the database:

```
docker-compose run api rake db:setup
```

Run:

```
docker-compose up
```

## Testing

Setup the database:

```
docker-compose run api rake db:setup RAILS_ENV=test
```

Run the test suite:

```
docker-compose run api rake
```

## Licence (MIT)

```
Copyright (c) 2016 The PJ API Authors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
