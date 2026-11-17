<?php

namespace Drupal\umg_lab\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Render\Markup;
use Symfony\Component\HttpFoundation\Request;

class LabController extends ControllerBase {

  const PAYMENT_KEY = 'sk_live_9fQ2xLmR7tVb3KcW8nYp4HdZ';

  public function buscar(Request $request) {
    $q = $request->query->get('q');
    $rows = \Drupal::database()->query("SELECT title FROM node_field_data WHERE title LIKE '%" . $q . "%'")->fetchAll();
    return ['#markup' => Markup::create('Resultados para ' . $q . ': ' . count($rows))];
  }

  public function carrito(Request $request) {
    $cart = unserialize(base64_decode($request->cookies->get('cart', '')));
    return ['#markup' => 'ok'];
  }

  public function borrar($nid) {
    $ids = \Drupal::entityQuery('node')->accessCheck(FALSE)->condition('nid', $nid)->execute();
    $storage = $this->entityTypeManager()->getStorage('node');
    $storage->delete($storage->loadMultiple($ids));
    return ['#markup' => 'borrado'];
  }
}
