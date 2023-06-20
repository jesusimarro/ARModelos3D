//
//  ViewController.swift
//  modelos3d
//
//  Created by estech on 3/5/23.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var label: UILabel!
    var cuenta = 10
    var temp = Each(1).seconds

    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.session.run(configuration)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)

    }

    func setTiempo() {
        self.temp.perform { () -> NextStep in
            self.cuenta -= 1
            self.label.text = String(self.cuenta)

            if self.cuenta == 0 {
                self.label.text = "Has perdido"
                return .stop
            }

            return .continue
        }
    }


    @IBAction func boton(_ sender: Any) {
        self.setTiempo()
        addNode()
        self.playButton.isEnabled = false //Para que no se pueda pulsar dos veces el botón
    }

    func addNode() {
        let jellyScene = SCNScene(named: "art.scnassets/Jellyfish.scn") // Ruta donde está el modelo
        let jellyNode = jellyScene?.rootNode.childNode(withName: "Sphere", recursively: false) // Sphere es el nombre del nodo que hay dentro
        jellyNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -1, secondNum: 1))
        jellyNode?.name = "Medusa"
        self.sceneView.scene.rootNode.addChildNode(jellyNode!)
    }


    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates) // hitTest devuelve un array

        if hitTest.isEmpty {
            print("No has tocado nada")
        } else {
            let results = hitTest.first!
            let nodeName = results.node.name
            print("Has tocado \(nodeName ?? "un objeto en realidad aumentada")")

            let node = results.node
            //Iniciar la animación solo si no hay otra animación en curso sobre el nodo
            if node.animationKeys.isEmpty {

                SCNTransaction.begin() //Comienza la transacción de la animación
                //Todo lo que haya aquí forma parte del bloque de la transacción
                self.animateNode(node: node)

                SCNTransaction.completionBlock = {
                    //Este bloque se ejecutará cuando termine la transacción
                    node.removeFromParentNode() //Elimina el nodo que hemos tocado

                    self.cuenta = 10
                    self.addNode()
                }

                SCNTransaction.commit() //Ejecuta la transacción
            }

        }
    }

    func animateNode(node: SCNNode) {

        //Tomar la posición inicial
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position //Posición inicial

        let posicionInicial = node.presentation.position

        spin.toValue = SCNVector3(x: posicionInicial.x - 0.2, y: posicionInicial.y - 0.2, z: posicionInicial.z - 0.2)

        spin.duration = 0.1         // Velocidad de movimiento
        spin.autoreverses = true    // Movimiento de ida y vuelta
        spin.repeatCount = 5        // Repetir tantas veces la animación

        node.addAnimation(spin, forKey: "position")

    }


    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }

}
