package
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.ITickedObject;
    import com.pblabs.engine.core.InputKey;
    import com.pblabs.engine.core.ProcessManager;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;
    
    [SWF(frameRate="120")]
    public class exploringFlash3D extends Sprite implements ITickedObject
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
            
            for(var i:int=0; i<1000; i++)
                createParticle(Math.random() * 0xFFFFFF);

            ProcessManager.instance.addTickedObject(this);
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
       
        var curX:Number = 100;
        var curZ:Number = 0;
        var yRot:Number = -90;
        
        var inPos:Vector.<Number> = new Vector.<Number>;
        var outPos:Vector.<Number> = new Vector.<Number>;
        var outUvt:Vector.<Number> = new Vector.<Number>;

        public function onTick(dt:Number):void
        {
            var deltaX:Number = 0, deltaY:Number = 0;
            if(PBE.isKeyDown(InputKey.A))
                deltaX -= 4;
            
            if(PBE.isKeyDown(InputKey.D))
                deltaX += 4;
            
            if(PBE.isKeyDown(InputKey.W))
                deltaY += 4;
            
            if(PBE.isKeyDown(InputKey.S))
                deltaY -= 4;
            
            if(PBE.isKeyDown(InputKey.Q))
                yRot--;
            
            if(PBE.isKeyDown(InputKey.E))
                yRot++;
            
            // Move according to heading.
            var th:Number = (yRot / 90.0) * Math.PI; 
            curX += (Math.cos(th) * deltaX) + (-Math.sin(th) * deltaY);
            curZ += (Math.sin(th) * deltaX) + (Math.cos(th) * deltaY);
            
            var focalLength:Number = 1000;
            
            transform.perspectiveProjection.fieldOfView = 90;
            transform.perspectiveProjection.focalLength = focalLength;
            transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
            
            projectionMatrix = transform.perspectiveProjection.toMatrix3D();
            
            worldMatrix.identity();
            worldMatrix.prependTranslation(curX, 0, curZ);
            worldMatrix.appendRotation(yRot * 2, Vector3D.Y_AXIS);
            
            worldMatrix.append(projectionMatrix);
            
            var screenPos:Vector3D = new Vector3D();
            
            // Batch project everything.
            inPos.length = numChildren * 3;
            outPos.length = numChildren * 2;
            outUvt.length = numChildren * 3;
            
            for(var i:int=0; i<numChildren; i++)
            {
                var curThing:DO3D = getChildAt(i) as DO3D;
                if(!curThing)
                    continue;
                
                inPos[i*3 + 0] = curThing.worldPosition.x;
                inPos[i*3 + 1] = curThing.worldPosition.y;
                inPos[i*3 + 2] = curThing.worldPosition.z;
            }
            
            Utils3D.projectVectors(worldMatrix, inPos, outPos, outUvt);
            
            // Position everything.
            for(var i:int=0; i<numChildren; i++)
            {
                var curThing:DO3D = getChildAt(i) as DO3D;
                if(!curThing)
                    continue;
                
                var preZ:Number = outUvt[i*3 + 2];
                curThing.x = outPos[i*2+0] + stage.stageWidth / 2;
                curThing.y = outPos[i*2+1] + stage.stageHeight / 2;
                curThing.visible = preZ < 0;
                
                var scaleFactor:Number = 1; //focalLength / preZ;
                curThing.scaleX = scaleFactor;
                curThing.scaleY = scaleFactor;
            }
        }
        
        public final function transformVector(m:Matrix3D, i:Vector3D, o:Vector3D):void
        {
            var d:Vector.<Number> = m.rawData;
            o.x = i.x * d[0]  + i.y * d[1]  + i.z * d[2]  + d[3];
            o.y = i.x * d[4]  + i.y * d[5]  + i.z * d[6]  + d[7];
            o.z = i.x * d[8]  + i.y * d[9]  + i.z * d[10]  + d[11];
            o.w = i.x * d[12]  + i.y * d[13]  + i.z * d[14]  + d[15];
        }
    }
}