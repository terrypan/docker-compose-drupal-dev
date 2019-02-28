<?php

namespace Drupal\test_di_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\test_di_module\Services\HelloGenerator;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\Response;

class TestDIController extends ControllerBase  {

    // Added for DI
    private $helloGenerator;
    public function __construct(HelloGenerator $helloGenerator){
      $this->helloGenerator = $helloGenerator;
    }

    // Added for DI
    public static function create(ContainerInterface $container){
      $x = $container->get('test_di_module.hello_generator');
      return new static ($x);
    }

    public function say($count) {

      // 1. Simple response
      // return new Response('Hello'.$count);

      // 2. Response via direct access to "service"
      // $helloGenerator = new HelloGenerator();
      // $hello = $helloGenerator->getHello($count);
      // return new Response($hello);

      // 3. Dependency Injection
      $hello = $this->helloGenerator->getHello($count);
      return new Response($hello);

    }
}
