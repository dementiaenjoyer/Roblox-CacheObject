local Game = game;

-- Services
local Workspace = Game : GetService( "Workspace" );

-- Cache
local Infinite = math.huge;

local DrawingImmediate = DrawingImmediate;
local SetMetatable = setmetatable;

local MathRound = math.round;

local MathMax = math.max;
local MathMin = math.min;

local MathRad = math.rad;
local MathTan = math.tan;

local Vector3Zero = Vector3.zero;
local Vector3New = Vector3.new;

local Vector2New = Vector2.new;
local Color3New = Color3.new;

local White = Color3New( 1, 1, 1 );
local Black = Color3New( 0, 0, 0 );

local Tick = tick;

local FilledRectangle = DrawingImmediate.FilledRectangle;
local Rectangle = DrawingImmediate.Rectangle;
local Text = DrawingImmediate.OutlinedText;

-- Variables
local CurrentCamera = Workspace.CurrentCamera;

-- Classes
local CacheObject = { }; do
    CacheObject.__index = CacheObject;

    local RenderObjects = { }; do
        function RenderObjects.HealthBar( Self, Color )
            local Position, Size = Self : GetRender( );

            if ( not Position ) then
                return;
            end

            local PositionX = Position.X - 5;
            local PositionY = Position.Y;

            local Bottom = MathRound( PositionY + Size.Y );
            local Top = MathRound( PositionY );

            local MaxBarHeight = ( Bottom - Top );
            local Height = MathRound( MathMax( 0, MathMin( 1, Self.Health / Self.MaxHealth ) ) * MaxBarHeight );

            local Transparency = Self.Transparency;

            FilledRectangle( Vector2New( PositionX, Top - 1 ), Vector2New( 3, MaxBarHeight + 2 ), Black, Transparency, 0, 1 );
            FilledRectangle( Vector2New( PositionX + 1, Bottom - Height ), Vector2New( 1, Height ), Color, Transparency, 0 );
        end

        function RenderObjects.Tool( Self, Color )
            local Position, Size = Self : GetRender( );

            if ( not Position ) then
                return;
            end

            local Transparency = Self.Transparency;
            
            Text( Vector2New( Position.X + ( Size.X * .5 ), Position.Y + ( Size.Y + 1 ) ), 2, 13, Color, Transparency, Black, Transparency, Self.Tool, true );
        end

        function RenderObjects.Name( Self, Color )
            local Position, Size = Self : GetRender( );

            if ( not Position ) then
                return;
            end
            
            local Transparency = Self.Transparency;
            Text( Vector2New( Position.X + ( Size.X * .5 ), Position.Y - 17 ), 2, 13, Color, Transparency, Black, Transparency, Self.Name, true );
        end

        function RenderObjects.Box( Self, Color )
            local Position, Size = Self : GetRender( );

            if ( not Position ) then
                return;
            end
            
            local Transparency = Self.Transparency;

            Rectangle( Position, Size, Black, Transparency, 0, 3 );
            Rectangle( Position, Size, Color, Transparency, 0, 1 );
        end
    end

    function CacheObject : Initiate( Name, Callback )
        local ClassObject = SetMetatable( { }, self ); do
            ClassObject.Name = ( Name or "" );
        end Callback( ClassObject );

        return ClassObject;
    end

    CacheObject.Offset = Vector3New( 0, -.2, 0 );
    CacheObject.Size = Vector3New( 4.2, 5, 0 );

    CacheObject.Position = Vector3Zero;
    CacheObject.Transparency = 0;

    CacheObject.MaxHealth = 100;
    CacheObject.Health = 100;

    CacheObject.Configuration = { };
    CacheObject.Dead = Infinite;

    -- Methods
    do
        function CacheObject : GetRender( )
            local ViewportSize = CurrentCamera.ViewportSize;
            local FieldOfView = CurrentCamera.FieldOfView;

            local ScreenPosition = self : GetScreen( );

            if ( not ScreenPosition ) then
                return;
            end

            local Scale = ( 2 * ViewportSize.Y ) / ( ( 2 * ScreenPosition.Z * MathTan( MathRad( FieldOfView ) * .5 ) ) * 2 );

            local Size = self.Size;
                local SizeX = Size.X;
                local SizeY = Size.Y;
            
            local Height = MathRound( SizeY * Scale );
            local Width = MathRound( SizeX * Scale );

            return Vector2New( MathRound( ScreenPosition.X - ( Width * .5 ) ), MathRound( ScreenPosition.Y - ( Height * .5 ) ) ), Vector2New( Width, Height );
        end

        function CacheObject : GetScreen( )
            local Result, OnScreen = CurrentCamera : WorldToViewportPoint( self.Position + self.Offset );

            if ( not OnScreen ) then
                return;
            end

            return Result;
        end

        function CacheObject : Stepper( )
            local Configuration = self.Configuration;

            for Name, Callback in RenderObjects do
                local Color = Configuration[ Name ];

                if ( not Color ) then -- Want it disabled? Remove it from the table.
                    continue;
                end

                Callback( self, Color );
            end

            self.Transparency = ( 1 - MathMax( 0, MathMin( 1, ( Tick( ) - self.Dead ) * 2 ) ) );
        end

        function CacheObject : Respawn( )
            self.Dead = Infinite;
        end

        function CacheObject : Died( )
            if ( self.Dead ~= Infinite ) then
                return;
            end

            self.Dead = Tick( );
        end
    end
end

--[[
local Cache = { }; DrawingImmediate.GetPaint( 1 ) : Connect( function( )
    for _, Player in Players : GetPlayers( ) do
        local Character = Player.Character;

        if ( not Character ) then
            continue;
        end

        local RootPart = Character : FindFirstChild( "HumanoidRootPart" );

        if ( not RootPart ) then
            continue;
        end

        local Humanoid = Character : FindFirstChild( "Humanoid" );

        if ( not Humanoid ) then
            continue;
        end
        
        local Object = Cache[ Player ] or CacheObject : Initiate( Player.Name, function( Self )
            Cache[ Player ] = Self;
        end )

        local Health = Humanoid.Health;
        Object.Health = Health;
        
        if ( Health >= 1 ) then
            local Size = Character : GetExtentsSize( );
            Object.Size = Size;

            Object.Position = RootPart.Position;
            Object.Tool = "foid";

            Object : Respawn( );
        end

        if ( Health <= 0 ) then
            Object : Died( );
        end
        
        Object : Stepper( );
    end
end ) CacheObject.Configuration[ "Box" ] = White;
]]

return CacheObject;
