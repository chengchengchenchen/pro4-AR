//
//  Day31.swift
//  rayCast
//
//  Created by qjc on 2023/5/30.
//

import ARKit
import RealityKit
import SceneKit
var gestureStartLocation: SIMD3<Float>?
var cubeEntity: ModelEntity?

class ViewController: UIViewController, ARSessionDelegate {

    var models:[Entity]=[]
    var arView:ARView{
        return self.view as! ARView
    }
    
    override func loadView() {
        self.view = ARView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self
        arView.environment.sceneUnderstanding.options = []
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        arView.environment.sceneUnderstanding.options.insert(.physics)
        arView.debugOptions.insert(.showSceneUnderstanding)
        //arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        //configuration.sceneReconstruction = .mesh
        //configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
       
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapRecognizer)
        
    
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal).first {
            let resultAnchor = AnchorEntity(world: result.worldTransform)
            if(type==1){
                let entity = wordModel(word: words[ind], color: .black)
                resultAnchor.addChild(entity)
                models.append(entity)
                ind=(ind+1)%words.capacity
            }else if(type==2){
                let entity = arView.entity(at: tapLocation)
                if entity?.children.first != nil{
                    entity?.removeFromParent()
                    if let index = models.firstIndex(of: entity!){
                        models.remove(at: index)
                    }
                }
            }else if(type==3){
                let entity = arView.entity(at: tapLocation)
                if let firstChild = entity?.children.first{
                    firstChild.isEnabled.toggle()
                }
            }
        
            arView.scene.addAnchor(resultAnchor )
        }
    }

    
    func wordModel(word: Word, color: UIColor)->ModelEntity{
        let word_ = ModelEntity(mesh: .generateText(word.Eng), materials: [SimpleMaterial(color: color, isMetallic: false)])
        let wordChild = ModelEntity(mesh: .generateText(wordType[word.t]+word.Cn), materials: [SimpleMaterial(color: color, isMetallic: false)])
        
        word_.addChild(wordChild )
        wordChild.isEnabled=false
        wordChild.transform.translation.y-=15
        word_.scale=SIMD3(repeating: 0.01)
        word_.transform.translation.y+=0.15
        word_.generateCollisionShapes(recursive: true )
        arView.installGestures(.all, for: word_)

        return word_
        
    }
    
}
