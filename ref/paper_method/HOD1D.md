### Histogram of Oriented Gradients (HOG) Feature Descriptor

A feature descriptor is a representation of an image or an image patch that simplifies the image by extracting useful information and throwing away extraneous information. Typically, a feature descriptor converts an image of size $width \times height \times 3$ (channels ) to a feature vector / array of length $n$. Clearly, the feature vector is not useful for the purpose of viewing the image. But, it is very useful for tasks like image recognition and object detection. HOG is not only able to identify the image edge, but also provide the edge direction as well. This is done by extracting the gradient and orientation (magnitude and direction) of the edges.

In the HOG feature descriptor, the distribution (histograms) of directions of gradients (oriented gradients) are used as features. Gradients (directional change in the intensity or color in an image) of an image are useful because the magnitude of gradients is large around edges and corners (regions of abrupt intensity changes) and we know that edges and corners pack in a lot more information about object shape than flat regions.

**Definition:** ``HOG feature descriptor counts the occurrences of gradient orientation in localized portions of an image.``

#### Step 1: Prepocessing

HOG feature descriptor is calculated on a fixed aspect ratio of patches of an image. For instance, if the image is of size $72 \times 475$, then a patch size of $100 \times 200$ can be cropped out of an image and resized to $64 \times 128$. 

#### Step 2: Calculate Gradients
The next step is to calculate the gradient for every pixel in the image. Gradients are the small change in the $x$ and $y$ directions. This process will give two new matrices – one storing gradients in the $x$-direction ($G_x$) and the other storing gradients in the $y$-direction ($G_y$). This is similar to using a **Sobel Kernel** of size $1$. The magnitude would be higher when there is a sharp change in intensity, such as around the edges.

#### Step 3: Calculate the Magnitude and Orientation
The gradients calculated in the **Step 2** will determine the magnitude and direction for each pixel value. For this step, the Pythagoras theorem is used to calculate the ``Total Gradient Magnitude``, which is given by
$$\text{Total Gradient Magnitude} = \sqrt{G_x^2 + G_y^2}$$

And, the ``orientation`` (or direction) by 
$$tan(\phi) = G_y/G_x$$
$$\phi = atan(G_y/G_x)$$

#### Step 4: Calculate Histogram of Gradients in $8 \times 8$ cells ($9 \times 1$)
+ Method 1: generate a frequency table that denotes angles and the occurrence of these angles in the image. This frequency table can be used to generate a histogram with angle values on the $x$-axis and the frequency on the $y$-axis.
+ Method 2: pre-determine the bin size, like $20$, then the number of buckets is $9$. Again, for each pixel, we will check the orientation, and store the frequency of the orientation values in the form of a $9 \times 1$ matrix. 
+ Method 3: use the weighted gradient magnitude instead of frequency to fill the values in the matrix - Bin $20-40$, orientation is $36$ and magnitude is $13.6$, then $20: (40-36)/20 \cdot 13.6$, while $40: (36-20)/36 \cdot 13.6$.

The histograms created in the HOG feature descriptor are not generated for the whole image. Instead, the image is divided into $8 \times 8$ cells, and the histogram of oriented gradients is computed for each cell. By doing so, we get the features (or histogram) for the smaller patches which in turn represent the whole image.

#### Step 5: Normalize Gradients in $16 \times 16$ Cell ($36 \times 1$)
Although we already have the HOG features created for the $8 \times 8$ cells of the image, the gradients of the image are sensitive to the overall lighting. This means that for a particular picture, some portion of the image would be very bright as compared to the other portions. This lighting variation can be reduced by normalizing the gradients by taking $16 × 16$ blocks (four $8 \times 8$ cells). 

Here, we will be combining four $8 \times 8$ cells to create a  $16 \times 16$  block. And we already know that each $8 \times 8$ cell has a $9 \times 1$ matrix for a histogram. So, we would have four $9 \times 1$ matrices or a single $36 \times 1$ matrix. To normalize this matrix, we will divide each of these values by the square root of the sum of squares of the values. Mathematically, for a given vector $V$:
$$V  = (a_1, a_2, \dots, a_m)$$
$$r = \sqrt{a_1^2 + a_2^2 + \dots + a_m^2}$$
$$\text{Normalized Vector} = (a_1/r, a_2/r, \dots, a_m/r)$$

#### Step 6: Features for the Complete Image

$$\text{Number of Features} = \text{Number of Blocks} \times m \times 1 = 7 \cdot 15 \cdot 36 \cdot 1 = 3780$$
