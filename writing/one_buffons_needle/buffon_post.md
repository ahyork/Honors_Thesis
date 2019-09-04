---
layout: post
title: Monte Carlo simulation of Buffon's Needle
snippet: Modeling the probability of a needle intersecting a line when randomly dropped on a floor exhibiting infinite, equally spaced parallel lines. Uses analytical, geometrical, and simulation approaches to find the probability of a needle intersecting a line on the floor. 
tags: [simulation, computer programming]
author: Arthur York
---

Buffon's Needle is a probability problem originally discussed in the 18th century. The problem revolves around needles of a given length and a floor marked with infinite parallel lines, each equidistant from each other. The goal is to determine the probability that a needle randomly thrown anywhere on the floor intersects one of those lines based upon the length of the needle and the distance between the lines on the floor. In this post, I derive the analytical solution of this probability and conduct a Monte Carlo simulation of Buffon's needle problem in the Julia programming language.

I made two simplifying assumptions in this work. The first is that the length of the needle is less than the distance between the lines on the floor. This eliminates the possibility that the needle intersects two or more lines. The second assumption is that needles land on the floor at random positions and with random orientations.

{:.centerr}
<figure>
    <img src="/images/Buffon/buffon_floor.png" alt="image" style="width: 70%;">
    <figcaption>Fig 1. An example of Buffon's Needle, where the vertical strips are the parallel lines on the floor, and the arrows represent the needles</figcaption>
</figure>

## Representing the Needle and the Floor

The position and orientation of a needle thrown onto the floor can be described by the Cartesian coordinates $(x,y)$ of its center and the angle $\theta$ it makes with the vertical. The floor can be described by the distance $\ell$ between successive parallel lines repeating ad infinitum in the $x$-direction.

Note that the $y$ coordinate of a needle does not influence whether it intersects a line on the floor or not.
Therefore, we do not need to consider it for our calculations; we only need to keep track of the $x$-coordinate and angle $\theta$ of a needle during the simulation.

The successive lines on the floor are a distance $\ell$ apart and repeat infinitely in the $x$-direction. The simulation needs to model a needle being dropped anywhere on this infinite floor, but it is impractical to create an infinite floor for the simulation. If we define two lines and the space between them as a chunk, we can see that the fraction of needles that intersect a line in each chunk is expected to be the same. Thus for our simulation, we can consider only a single chunk $0 \leq x \leq \ell$ and arrive at the answer to Buffon's needle problem, which concerns an infinite floor.

It would be proper to allow the angle with the vertical $0 \leq \theta \leq 2\pi$, however we can take advantage of some rotational symmetry. A needle with angle $\theta$ appears equivalent to a needle with the same coordinates and angle of $\theta + \pi$. We therefore only allow $0 \leq \theta \leq \pi$ in our calculations. For example, since $0 \leq \theta \leq \pi$ contains $\frac{\pi}{4}$ there is no need to test $\frac{5\pi}{4}$ because they would describe the same orientation of a needle.

#### The State Space of a Needle

{:.centerr}
<figure>
    <img src="/images/Buffon/buffon_needle.png" alt="image" style="width: 70%;">
    <figcaption>Fig 2. A needle with its state labeled</figcaption>
</figure>

The "state space" $R$ of a needle, and therefore the simulation box for our simulation is:

$$R = \left \{ (x,\theta) \mid 0\leq x\leq \ell,0\leq \theta \leq \pi \right \}$$

Randomly throwing a needle on the floor in our simulation is equivalent to drawing a uniformly distributed sample from the state space $R$.

#### Data Structure for a Needle

I created a `Needle` struct in order to conveniently store all the relevant attributes of a needle in one data structure in Julia.

{% highlight julia %}
struct Needle
    x::Number
    L::Number
    θ::Number
end
{% endhighlight %}

For the floor, I describe it by a single value `ℓ::Number`, the distance between two successive lines.

## Simulation of Needle Throws

For the simulation, I created a `throw_needle` function that generates a `Needle` uniformly distributed in the state space given by the length of the needles $L$ and distance $\ell$ between the lines on the floor:

{% highlight julia %}
function throw_needle(ℓ::Number, L::Number)
    return Needle(rand() * ℓ, L, rand() * π)
end
{% endhighlight %}

This function essentially "samples" the needle state space.

## Checking for Needles Intersecting a Line

A needle will intersect a line if part of the needle overlaps $x=0$ or $x=\ell$. We check for overlap by checking the $x$-coordinates of the endpoints of the needles. If one of those is outside the simulation box (one is less than $0$ or greater than $\ell$), then the needle intersects a line. 

The $x$-coordinates of the two endpoints of a needle are found as follows. First, take the $x$-coordinate for the center of the needle. Then add or subtract half of the length of the projection of the needle onto the $x$-axis, $\frac{L}{2}\sin\theta$. This generates two conditions for whether or not a needle crosses a line. A needle with coordinate $x$ and angle $\theta$ intersects a line if and only if:

<center>$x+\frac{L}{2}\sin\theta\geq \ell$ or $x-\frac{L}{2}\sin\theta\leq 0$</center>

The following function in Julia takes a `Needle` as an argument and checks if it intersects a line on the floor:

{% highlight Julia %}
function check_intersection(needle::Needle, ℓ::Number)
	if needle.x + needle.L / 2 * sin(needle.θ) >= ℓ
		return true
	elseif needle.x - needle.L / 2 * sin(needle.θ) <= 0
		return true
	else
		return false
	end
end
{% endhighlight %}

## Calculating the Probability Analytically

To analytically obtain the probability of a needle intersecting a line, we can look at the fraction of the state space that leads to a needle intersecting a line. Visually, we can graph the state space $R$ of the needle in the $(x,\theta)$ plane and shade the regions of state space that result in needles intersecting lines. These regions are described by $x+\frac{L}{2}\sin\theta>\ell$ and $x-\frac{L}{2}\sin\theta<0$. The total areas of these regions divided by the total area of the state space is then the probability of a needle intersecting a line.

The area of the total state space of the needle is:

<center>$$A_T=\int_{0}^{\pi}\int_0^{\ell} dx d\theta=\ell\pi$$</center>

The area of the state space satisfying $x-\frac{L}{2}\sin\theta\leq0$ is:

<center>$$A_1=\int_{0}^{\pi}\left(\frac{L}{2}\sin\theta\right)d\theta=L$$</center>

The area of the state space satifying $x+\frac{L}{2}\sin\theta\geq \ell$ is:

<center>$$A_2=\int_{0}^{\pi}\ell d\theta-\int_{0}^{\pi}\left(\ell-\frac{L}{2}\sin\theta\right)d\theta=\int_{0}^{\pi}\left(\frac{L}{2}\sin\theta\right)d\theta=L$$</center>

See Fig. 3 for a visualization of these regions in the state space.

Therefore, the total area of needle state space that results in intersection with a line on the floor is:

<center>$A_1+A_2=L+L=2L$</center>

and thus the probability of a needle landing on a line is:

<center>$\dfrac{A_1+A_2}{A_T}=\dfrac{2L}{\ell\pi}$</center>

## Calculating the Probability Through a Monte Carlo Simulation

To calculate Buffon's needle probability with a Monte Carlo simulation, we will "throw" needles on the floor with our function `throw_needle`, which draws uniformly random $x$ positions and uniformly random angles $\theta$ to decide the state of the thrown needle. This is effectively sampling a point from the needle state space $R$. We then keep track of the fraction of the needles that intersected a line as an estimate of Buffon's needle probability. We expect the fraction of needles intersecting a line in the simulation to be $2L/(\ell \pi)$.

{% highlight julia %}
function simulate_buffons_needles(nb_throws::Number, L::Number, ℓ::Number)
	nb_overlaps = 0
	for t = 1:nb_throws
		needle = throw_needle(ℓ, L)
		if check_intersection(needle, ℓ)
			nb_overlaps += 1
		end
	end
	return nb_overlaps / nb_throws # estimate for probability of intersection
end
{% endhighlight %}

I then plotted the randomly generated needles as points in their state space $R$. The needles that were found to intersect a line on the floor are colored with blue. Those that didn't intersect a line are colored red. This visualization is valuable because, once we plot the data, the curves $x+\frac{L}{2}\sin\theta\geq \ell$ and $x-\frac{L}{2}\sin\theta\leq 0$ and their areas $A_2$ and $A_1$ from the analytical approach are apparent. Also note that if $\theta$ is close to zero or $\pi$, it is highly unlikely (more red) that a needle will intersect a line because it is almost parallel with the lines on the floor.

{:.centerr}
<figure>
    <img src="/images/Buffon/statespace.png" alt="image" style="width: 70%;">
    <figcaption>Fig 3. A plot of the randomly generated needles in their statespace, with blue (red) showing needles that intersected (did not intersect) a line on the floor</figcaption>
</figure>

When I ran the simulations, I would compare the theoretical probability $\frac{2L}{\ell\pi}$ with the probability calculated from the simulation. I chose $L=10$ for the length of the needle and $\ell=30$ as the distance between the lines on the floor. Using these numbers in the analytical solution, I expect a probability around 0.2122 (21.22%) for a needle to intersect with a line. The simulation generating the state space graph above, comprised of 2500 needle throws, gave a simulated probability of about 0.2 (20.00%). :thumbsup:

To check the accuracy of these results, I made another plot that showed the estimated probability-- the fraction of needles that intersect a line in a simulation-- as a function of the number of throws. This plot displays error bars describing the range of simulated probabilities based on the standard deviation of the estimates from multiple simulations with that number of throws. We expect that, as we use more needle throws to estimate the probability of intersecting a line, the estimate will become more accurate, and errors will be smaller.

{:.centerr}
<figure>
    <img src="/images/Buffon/error_bar.png" alt="image" style="width: 70%;">
    <figcaption>Fig 4. This shows that as the number of throws increases, the error decreases and the simulated value is more likely to be close to the analytical value (horizontal, red dashed line)</figcaption>
</figure>

We see from this graph the number of needle throws in a Monte Carlo simulation required to obtain an estimate of Buffon's needle probability with a given confidence.
