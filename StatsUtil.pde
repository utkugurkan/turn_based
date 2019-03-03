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
