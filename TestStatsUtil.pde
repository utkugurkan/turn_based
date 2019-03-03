TestStatsUtil testStatsUtil = new TestStatsUtil();

class TestStatsUtil {
  public void runAllTests() {
    println();
    println("Running TestStatsUtil...");
    testRandomTruncatedGaussian();
  }
  
  private void testRandomTruncatedGaussian() {
    println("Running TestStatsUtil.testRandomTruncatedGaussian");
    
    int[] bucketCounts = {0, 0, 0, 0};
    // Calculate a bunch of random numbers
    for (int i = 0; i < 99999; ++i) {
      float num = randomTruncatedGaussian(0f, 4f, 1f, 1f);
      ++bucketCounts[int(num)];
    }
    // Print results.
    for (int i = 0; i < bucketCounts.length; ++i) {
      println(i + ":  " + bucketCounts[i]); 
    }
    println("Test complete.");
  }
  
}
