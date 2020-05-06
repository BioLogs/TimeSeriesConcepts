#' ---
#' title: Introduction to Time Series II
#' author: Edwin Bedolla
#' date: 6th April 2020
#' ---
#' 
#' In this document, the main statistics such as the **mean function**, **autocovariance function**
#' and **autocorrelation function** will be described, along with some examples.
#' 
#' We will import all of the necessary modules first.
#' 
#' 
#' 
#+ results = "hidden"

using StatsPlots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames

gr()

# Ensure reproducibility of the results
rng = MersenneTwister(8092)

#' 
#' 
#' 
#' 
#' ## Descriptive statistics and measures
#' 
#' A full description of a given time series is always given by the **joint distribution function**
#' of the time series which is a multi-dimensional function that is very difficult to track for
#' most of the time series that are dealt with.
#' 
#' Instead, we usually work with what's known as the **marginal distribution function** defined as
#' 
#' $$
#' F_t(x) = P \{ x_t \leq x \}
#' $$
#' 
#' where $P \{ x_t \leq x \}$ is the probability that the *realization* of the time series $x_t$
#' at time $t$ is less or equal that the value of $x$.
#' Even more common is to use a related function known as the **marginal density function**
#' 
#' $$
#' f_t(x) = \frac{\partial F_t(x)}{\partial x}
#' $$
#' 
#' and when both functions exist they can provide all the information needed to do meaningful
#' analysis of the time series.
#' 
#' ### Mean function
#' With these functions we can now define one of the most important descriptive measures,
#' the **mean function** which is defined as
#' 
#' $$
#' \mu_{xt} = E(x_t) = \int_{-\infty}^{\infty} x f_t(x) dx
#' $$
#' 
#' where $E$ is the *expected value operator* found in classical statistics.
#' 
#' ### Autocovariance and autocorrelation
#' We are also interested in analyzing the dependence or lack of between realization values in different
#' time periods, i.e. $x_t$ and $x_s$; in that case we can use classical statistics to define two very
#' important and fundamental quantities.
#' 
#' The first one is known as the **autocovariance function** and it's defined as
#' 
#' $$
#' \gamma_{x} (s, t) = \text{cov}(x_s,x_t) = E[(x_s - \mu_s)(x_t - \mu_t)]
#' $$
#' 
#' where $\text{cov}$ is the [covariance](https://en.wikipedia.org/wiki/Covariance) as defined in
#' classical statistics. A simple way of defining the *autocovariance* is the following
#' 
#' 
#' > The **autocovariance** tells us about the *linear* dependence between two points on the same
#' > time series observed at different times.
#' 
#' 
#' Normally, we know from classical statistics that if for a given time series $x_t$ we should have
#' $\gamma_{x} (s, t) = 0$ then it means that there is no linear dependence between $x_t$ and
#' $x_s$ at time periods $t$ and $s$; but this does not mean that there is **no** relation between them
#' at all. For that, we need another measure that we describe below.
#' 
#' We now introduce the **autocorrelation function** (ACF) and it's defined as
#' 
#' $$
#' \rho(s,t) = \frac{\gamma_{x} (s, t)}{\sqrt{\gamma_{x} (s, s) \gamma_{x} (t, t)}}
#' $$
#' 
#' which is a measure of **predictability** and we can define it in words as follows
#' 
#' > The **autocorrelation** measures the *linear predictability* of a given time series $x_t$ at
#' > time $t$, using values from the same time series but at time $s$.
#' 
#' This measure is very much related to [Pearson's correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient)
#' from classical statistics, which is a way to measure the relationship between values.
#' 
#' The range of values for the ACF is $-1 \leq \rho(s,t) \leq 1$; when $\rho(s,t) = 1$
#' it means that a *linear model* can perfectly describe the realization of the time series at time $t$
#' provided with the realization at time $s$, e.g. a trend goind upwards, on the other hand,
#' if $\rho(s,t) = -1$ would mean that the realization of the time series $x_t$ decrease while the realization
#' $x_s$ is increasing.
#' 
#' ## Example
#' Let's look at an example for the particular case of the *moving average*. We will
#' be working out the analytic form of the *autocovariance function* and *ACF* for the moving average
#' while also providing the same results numerically using `Julia`.
#' 
#' Recall the 3-valued moving average to be defined as
#' 
#' $$
#' v_t = \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)
#' $$
#' 
#' Let's plot the moving average again. We will create a very big time series for the sake
#' of numerical approximation below.
#' 
#' First, we create the white noise time series.
#' 
#' 
#' 
#+ results = "hidden"

# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)))
# Create a DataFrame of the TimeSeries for easier handling
df_ts = DataFrame(ts)

#' 
#' 
#' 
#' 
#' Then, as before, we compute the 3-valued moving average.
#' 
#' 
#' 
#+ results = "hidden"

# Compute the 3-valued moving average
moving_average = moving(mean, ts, 3)
# Create a DataFrame of the TimeSeries for easier handling
df_average = DataFrame(moving_average)

#' 
#' 
#' 
#' 
#' Recall what these look like in a plot. We just plot the first 100 elements in
#' the time series to avoid having a very cluttered plot.
#' 
#' 
#' 
#+ 

@df df_ts plot(:timestamp[1:100], :A[1:100], label = "White noise")
@df df_average plot!(:timestamp[1:100], :A[1:100], label = "Moving average")

#' 
#' 
#' 
#' 
#' We are now ready to do some calculations. First, we invoke the definition of the
#' *autocovariance function* and apply it to the moving average
#' 
#' $$
#' \gamma_v(s,t)=\text{cov}(v_s,v_t)=
#' \text{cov}\{\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right),
#' \frac{1}{3} \left( w_{s-1} + w_{s} + w_{s+1} \right)\}
#' $$
#' 
#' and now we need to look at some special cases.
#' 
#' - When $s = t$ we now have the following
#' 
#' $$
#' \gamma_v(t,t)=\text{cov}(v_t,v_t)=
#' \text{cov}\{\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right),
#' \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)\}
#' $$
#' 
#' then, by the property of
#' [covariance of linear combinations](https://en.wikipedia.org/wiki/Covariance#Covariance_of_linear_combinations)
#' we have the following simplification
#' 
#' $$
#' \gamma_v(t,t)=\text{cov}(v_t,v_t)=
#' \frac{1}{9}\{\text{cov}(w_{t-1},w_{t-1}) + \text{cov}(w_{t},w_{t})
#' + \text{cov}(w_{t+1},w_{t+1})\}
#' $$
#' 
#' and because $\text{cov}(U,U) = \text{var}(U)$ for a random variable $U$, for a white
#' noise random variable we have $\text{var}(w_t)=\sigma^2_{wt}$, thus
#' 
#' $$
#' \gamma_v(t,t)=\text{cov}(v_t,v_t)= \frac{3}{9} \sigma^2_{wt}
#' $$
#' 
#' In this case, recall that our white noise is normally distributed
#' $w_t \sim \mathcal{N}(0,\sigma^2_{wt})$ with $\sigma^2_{wt}$ so the true expected
#' value is the following:
#' 
#' 
#' 
#+ 

true_γ = 3 / 9

#' 
#' 
#' 
#' 
#' 
#' 
#' We will try to compute the *autocovariance function* using classical statistics
#' by means of the `cov` function in `Julia`. We need to pass it the time series like
#' so
#' 
#' 
#' 
#+ 

γ_jl = cov(df_average[:, :A], df_average[:, :A])

#' 
#' 
#' 
#' 
#' 
#' 
#' And we can see that the value is quite similar. The error must come from the fact
#' that we may need a bigger ensemble of values, but this should suffice.
#' 
#' - When $s = t + 1$ we now have the following
#' 
#' $$
#' \gamma_v(t+1,t)=\text{cov}(v_{t+1},v_t)=
#' \text{cov}\{\frac{1}{3} \left( w_{t} + w_{t+1} + w_{t+2} \right),
#' \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)\} \\
#' \gamma_v(t+1,t)=\frac{1}{9}\{\text{cov}(w_{t},w_{t}) + \text{cov}(w_{t+1},w_{t+1})\} \\
#' \gamma_v(t+1,t)=\frac{2}{9} \sigma^2_{wt}
#' $$
#' 
#' So the true value is now
#' 
#' 
#' 
#+ 

true_γ = 2 / 9

#' 
#' 
#' 
#' 
#' 
#' 
#' To check this, we perform the same operations as before, but this time, we need
#' to *move* the time series one time step with respect to itself.
#' 
#' 
#' 
#+ 

# Remove the last element from the first and start with the second element
γ_jl = cov(df_average[1:(end-1), :A], df_average[2:end, :A])

#' 
#' 
#' 
#' 
#' 
#' 
#' Great! Within a tolerance value, this is quite a nice estimate. It turns out that
#' for the cases $s = t + h$ where $h \geq 2$, the value for the *autocovariance*
#' is zero. We'll check it numerically here.
#' 
#' 
#' 
#+ 

# Remove the last element from the first and start with the second element
γ_jl = cov(df_average[1:(end-3), :A], df_average[4:end, :A])

#' 
#' 
#' 
#' 
#' 
#' 
#' It's actually true, a value very close to zero but, ¿why? It's easy to see
#' if one applies the *autocovariance function* definition and checks the case
#' $s = t + 3$, and so on.
#' 
#' Let's now focus on the **ACF** for a 3-valued moving average.
#' We have several cases, like before.
#' 
#' - When $s = t$ we now have the following
#' 
#' $$
#' \rho_v(t,t)=\frac{\gamma_v(t,t)}{\sqrt{\gamma_v(t,t)\gamma_v(t,t)}}\\
#' \rho_v(t,t)=\frac{\gamma_v(t,t)}{\gamma_v(t,t)} = 1
#' $$
#' 
#' so it turns out that the true value is $\rho_v(t,t)=1$, and we can check this using
#' the `cor` function to compute the correlation coefficient in `Julia` as an estimate
#' for the *ACF*
#' 
#' 
#' 
#+ 

ρ = cor(df_average[:, :A], df_average[:, :A])

#' 
#' 
#' 
#' 
#' 
#' 
#' - When $s = t + 1$ we now have the following
#' 
#' $$
#' \rho_v(t+1,t)=\frac{\gamma_v(t+1,t)}{\sqrt{\gamma_v(t+1,t+1)\gamma_v(t,t)}}\\
#' $$
#' 
#' recall from before that $\gamma(t,t)=3/9 \sigma_{vt}^2$ for a white noise time series,
#' and we also have $\gamma(t+1,t)=2/9 \sigma_{vt}^2$, so the *ACF* is now
#' 
#' $$
#' \rho_v(t+1,t)=\frac{2/9 \sigma_{vt}^2}{\sqrt{(3/9 \sigma_{vt}^2)(3/9 \sigma_{vt}^2)}}\\
#' \rho_v(t+1,t)=\frac{18 \sigma_{vt}^2}{27 \sigma_{vt}^2}\\
#' \rho_v(t+1,t)=\frac{2}{3}
#' $$
#' 
#' which is the true value
#' 
#' 
#' 
#+ 

true_ρ = 2 / 3

#' 
#' 
#' 
#' 
#' and again, we can check this value numerically
#' 
#' 
#' 
#+ 

ρ = cor(df_average[1:(end-1), :A], df_average[2:end, :A])

#' 
#' 
#' 
#' 
#' Lastly, like with the *autocovariance*, the *ACF* for the cases $s = t + h$ where $h \geq 2$
#' is zero as seen below
#' 
#' 
#+ 

ρ = cor(df_average[1:(end-3), :A], df_average[4:end, :A])

