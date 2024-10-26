# nich.dk

## Theme
https://github.com/hanwenguo/hugo-theme-nostyleplease

## Development instructions

```bash
git clone git@github.com:nicholas-mn/nich.dk.git
cd nich.dk/
git submodule update --init
```

### Create new post
```bash
hugo new content content/posts/new-website.md
```

## Create "page" without date in top right corner
Add the following to the [front-matter](https://gohugo.io/content-management/front-matter/#layout)
```toml
layout = 'page'
```