
local requireContent = { 1997114381 }
for _, id in pairs( requireContent ) do
    if file.Exists('cache/workshop/' .. id .. '.gma', 'GAME') then
        game.MountGMA( 'cache/workshop/' .. id .. '.gma' )
    else
        steamworks.DownloadUGC( id, function( path, f )
            game.MountGMA( path )
        end)
    end
end

