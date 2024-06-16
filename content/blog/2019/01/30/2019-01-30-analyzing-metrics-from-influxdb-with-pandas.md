---
layout: post
title: Analyzing metrics from InfluxDB with Pandas
date: 2019-01-30 10:35:00+03:00
categories: tutorials influxdb python pandas seaborn
---

Our team recently started using the [InfluxData stack][1] to collect metrics
from our apps (we may transfer logs and other time-series stuff to it, but
that's another story) and here is one feature that made me absolutely to fall in
love with InfluxDB &mdash; the official [Pandas][2] [integration][3]. In this
blog post I will briefly tell you what is so amazing about this integration and
why you definitely should try it.

First of all, let's start with the installation of what we need for this
tutorial:

```
pip3 install influxdb pandas seaborn
```

[`seaborn`][4] is a nice wrapper around [`matplotlib`][5] that provides
developers with some routines related to plotting their data and stats.

Having that installed and the InfluxDB instance running let's get started with
the actual coding.

```python
from influxdb import DataFrameClient

client = DataFrameClient(
    'localhost', # DB server hostname
    1000, # DB server port
    'lrdata', # DB user
    '12345678', # Password
    'metrics' # DB name
)
# Here we fetch the execution timings for a hypothetical JSON RPC method
# providing registration to the service. This uses InfluxQL.
# NOTE: This function returns a Pandas dataframe!
res = client.query(f'select "execution_time" from "rpc_api.register"')
res = res['rpc_api.register']
```

Now we have a Pandas dataframe and we can easily fetch some statistics from it:

```python
mean_time = res.mean()
median_time = res.median()
```

And we won't stop with that! Let's build some histogram and plots that will
give us more insight into the performance:

```python
import seaborn

# We can build a histogram
seaborn.distplot(res)

# Or just draw all measures in a single plot
# 1. Add index (timestamps) as a separate column
res['time'] = res.index
# 2. Draw the actual plot
seaborn.lineplot(x='time', y='execution_time', data=res)

# CDF is also easy and sometimes easier to read than histograms
seaborn.distplot(res, hist=False, kde_kws=dict(cumulative=True))
```

Use `.get_figure().savefig('plot_name.png')` on any of the plotting expressions
to save your plots to files.

You can check out how it works in [IPython Notebook][6] in [this Gist][7].

So as you can see you can extract and visualize your metrics statistics from
InfluxDB with a couple lines of Python. Have fun!

[1]: https://www.influxdata.com/time-series-platform/
[2]: https://pandas.pydata.org
[3]: https://influxdb-python.readthedocs.io/en/latest/examples.html#tutorials-pandas
[4]: https://seaborn.pydata.org
[5]: https://matplotlib.org
[6]: https://ipython.org/notebook.html
[7]: https://gist.github.com/eugene-babichenko/990bfc1bb7d5455a931d3e6348fc2cf0
