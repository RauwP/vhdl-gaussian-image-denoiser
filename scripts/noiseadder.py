import numpy as np

def flip_channels_to_max(
    in_file: str,
    out_file: str,
    image_height=256,
    image_width=256,
    channels=3,
    flip_probability=0.05
):
    """
    Reads a 256x256 raw image with 'channels' channels (e.g., 3 for RGB),
    then flips one or more channels to 255 with an independent probability
    for each channel.

    Parameters
    ----------
    in_file : str
        Path to the input raw file.
    out_file : str
        Path for the output raw file.
    image_height : int, optional
        The height of the image in pixels. Default: 256.
    image_width : int, optional
        The width of the image in pixels. Default: 256.
    channels : int, optional
        Number of channels per pixel. Commonly 3 for standard RGB
        (24 bits total), or 24 if you truly have 24 bytes per pixel.
        Default: 3.
    flip_probability : float, optional
        Probability that any given channel (R, G, or B) in a pixel
        is flipped to 255. Default is 0.05 (5%).
    """

    # 1. Calculate expected size in bytes
    expected_size = image_height * image_width * channels

    # 2. Read the raw file into a 1D array of uint8
    data = np.fromfile(in_file, dtype=np.uint8)

    # 3. Check if the file size matches the expected size
    if data.size != expected_size:
        raise ValueError(
            f"Input file size ({data.size} bytes) does not match "
            f"the expected size of {expected_size} bytes for a "
            f"{image_height}x{image_width} image with {channels} channels."
        )

    # 4. Reshape to (height, width, channels)
    data = data.reshape((image_height, image_width, channels))

    # 5. Generate a random mask of shape (height, width, channels)
    #    Each channel has a 'flip_probability' chance to become 255
    flip_mask = np.random.rand(image_height, image_width, channels) < flip_probability

    # 6. Flip those channels to max (255)
    data[flip_mask] = 255

    # 7. Write out the modified data
    data.tofile(out_file)


input_file = "petruha.raw"   # e.g., 24-bit color raw file: 256×256×3
output_file = "petruha_noise.raw"

    # Each channel has a 5% chance to be flipped to 255
flip_channels_to_max(
    in_file=input_file,
    out_file=output_file,
    image_height=256,
    image_width=256,
    channels=3,      # 3 for standard 24-bit RGB, or 24 if actually 24 bytes/pixel
    flip_probability=0.05
)
print("Successfully flipped channels with an independent 5% probability.") 
