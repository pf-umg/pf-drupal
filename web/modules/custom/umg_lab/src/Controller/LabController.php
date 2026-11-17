<?php

namespace Drupal\umg_lab\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

/**
 * Controlador del laboratorio, version corregida (Entregable 3).
 *
 * - Sin llave de pago en el codigo (HC02): se lee desde Secrets Manager.
 * - Consulta con Entity Query y accessCheck(TRUE) (HC01, HC07).
 * - Salida con #plain_text, que escapa el HTML (HC08).
 * - Se elimina carrito() y su unserialize() (HC11).
 */
class LabController extends ControllerBase {

  /**
   * Busca nodos por titulo sin concatenar SQL.
   */
  public function buscar(Request $request) {
    $q = mb_substr((string) $request->query->get('q', ''), 0, 100);
    $ids = $this->entityTypeManager()->getStorage('node')->getQuery()
      ->accessCheck(TRUE)
      ->condition('title', $q, 'CONTAINS')
      ->range(0, 50)
      ->execute();
    return [
      '#plain_text' => 'Resultados para ' . $q . ': ' . count($ids),
      '#cache' => ['max-age' => 0],
    ];
  }

  /**
   * Borra un nodo solo si el usuario tiene permiso sobre ese nodo.
   */
  public function borrar($nid) {
    $node = $this->entityTypeManager()->getStorage('node')->load($nid);
    if (!$node || !$node->access('delete')) {
      throw new AccessDeniedHttpException();
    }
    $node->delete();
    return ['#plain_text' => 'Contenido borrado'];
  }

}
