package
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.InputKey;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;
    
    [SWF(frameRate="120")]
    public class exploringFlash3D extends Sprite
    {
        var spinner:Sprite;
        var worldMatrix:Matrix3D = new Matrix3D();
        var projectionMatrix:Matrix3D;
        
        public function exploringFlash3D()
        {
            PBE.startup(this);
            
            // Stick a spining sprite on screen.
            spinner = new Sprite();
            //addChild(spinner);
            
            spinner.graphics.beginFill(0xFF00FF);
            spinner.graphics.drawRect(-60, -60, 120, 120);
            spinner.graphics.endFill();
            
            spinner.graphics.lineStyle(0, 0x00FF00);
            spinner.graphics.moveTo( -40, -40);
            spinner.graphics.lineTo( 40, 40);

            spinner.graphics.lineStyle(0, 0xFFFFFF);
            spinner.graphics.moveTo( -40,  40);
            spinner.graphics.lineTo( 40, -40);
            
            spinner.x = 100;
            spinner.y = 100;
            
            for(var i:int=0; i<100; i++)
                createParticle(Math.random() * 0xFFFFFF);
            
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        public function createParticle(color:uint):void
        {
            var particle:DO3D = new DO3D();
            
            particle.graphics.beginFill(color, 0.5);
            particle.graphics.drawCircle(0, 0, 32);
            particle.graphics.endFill();
            
            particle.worldPosition.x = Math.random() * 200 - 100;
            particle.worldPosition.y = Math.random() * 200 - 100;
            particle.worldPosition.z = Math.random() * 200 - 100;
            
            addChild(particle);
        }
       
        var curX:int = 100;
        var curZ:int;
        
        public function onFrame(e:*):void
        {
            if(PBE.isKeyDown(InputKey.A))
                curX--;
            
            if(PBE.isKeyDown(InputKey.D))
                curX++;
            
            if(PBE.isKeyDown(InputKey.W))
                curZ++;
            
            if(PBE.isKeyDown(InputKey.S))
                curZ--;
            
            transform.perspectiveProjection.fieldOfView = 90;
            transform.perspectiveProjection.focalLength = 100;
            transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
            
            projectionMatrix = transform.perspectiveProjection.toMatrix3D();
            
            worldMatrix.identity();
            worldMatrix.prependTranslation(curX, 0, curZ);
            worldMatrix.appendRotation(getTimer() / 10, Vector3D.Y_AXIS);
            
            worldMatrix.append(projectionMatrix);
            
            // Position everything.
            for(var i:int=0; i<numChildren; i++)
            {
                var curThing:DO3D = getChildAt(i) as DO3D;
                if(!curThing)
                    continue;
                
                // Position it based on its transformed position.
                var screenPos:Vector3D = worldMatrix.transformVector(curThing.worldPosition);
                var preZ:Number = screenPos.z;
                screenPos.project();
                
                curThing.x = screenPos.x + stage.stageWidth / 2;
                curThing.y = screenPos.y + stage.stageHeight / 2;
                curThing.visible = preZ < 0;
            }
        }
    }
}