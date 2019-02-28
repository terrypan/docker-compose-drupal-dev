<?php

namespace Drupal\test_di_module\Services;

class HelloGenerator {
  public function getHello($count) {
    return "Gotten hello ".$count;
  }
}
