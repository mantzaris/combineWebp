# combineWebp
with Julia Lang, in Linux, combine all the 'webp' files of the same size within a directory

with **img2webp** installed, run the script as

```
julia combineWebp.jl
```

or provide the delay parameter value, an integer (controls the speed of image transitions)

```
julia combineWebp.jl 100
```

In simple terms: *if you have a directory with .webp files (image animations of the same size), drop this file in there and run the command to get a single file named output.webp which is all the webp animations combined*
