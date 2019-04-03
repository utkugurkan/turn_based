float randomTruncatedGaussian(float rangeMin, float rangeMax, float mean, float stdDev) {
  float normal = randomGaussian(mean, stdDev);
  while (normal < rangeMin || normal > rangeMax) {
    normal = randomGaussian(mean, stdDev);
  }
  return normal;
}

float randomGaussian(float mean, float stdDev) {
  return randomGaussian() * stdDev + mean;
}

// Returns a random value that contrasts the given value based on given parameters.
float randomContrastingValue(float value, float rangeMin, float rangeMax, float stdDev) {
  float rangeCenter = (rangeMax - rangeMin) / 2 + rangeMin;
  float valueDiff = value - rangeCenter;
  float contrastCenter = rangeCenter - valueDiff;
  return randomTruncatedGaussian(rangeMin, rangeMax, contrastCenter, stdDev);
}
