<?php

namespace Drupal\migration_scripts\Plugin\migrate\process;

use Drupal\migrate\ProcessPluginBase;
use Drupal\migrate\MigrateExecutableInterface;
use Drupal\migrate\Row;

/**
 * Provides a 'AuthorId' migrate process plugin.
 *
 * @MigrateProcessPlugin(
 *  id = "author_id"
 * )
 */
class AuthorId extends ProcessPluginBase {

  /**
   * {@inheritdoc}
   */
  public function transform($value, MigrateExecutableInterface $migrate_executable, Row $row, $destination_property) {
    // Loading the user by name
    if (!empty($author = \Drupal::entityTypeManager()->getStorage('user')
      ->loadByProperties(['name' => $value]))) {
      $author = array_shift($author);
      return $author->id();
    }
    else {
      return 1;
    }
  }

}
