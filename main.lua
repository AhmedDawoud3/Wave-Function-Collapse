require "lib.Utils"
Tile = require "Tile"

WIDTH, HEIGHT = 800, 800

-- Dim (dimension) is the number of tile per one row or column
DIM = 10

function love.load()
  love.window.setMode(WIDTH, HEIGHT)

  -- Set a random seed
  math.randomseed(os.time())

  -- Load The Images from the folder "tile"
  imagesData = {}
  for dir in io.popen([[dir "]] .. io.popen "cd":read '*l' .. [[\tiles" /b ]]):lines() do
    table.insert(imagesData, love.image.newImageData("tiles/" .. dir))
  end

  -- Set the defult filter to nearest neighbor to make the images crips
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- Initialize the tiles into an array
  tiles = {}
  for i in pairs(imagesData) do
    table.insert(tiles, Tile(imagesData[i], 0))

  end
  print(#tiles .. " tiles")

  -- Make a 2d grid to keep track of the tiles' states
  -- Initialize the grid with all options and not being collapsed
  Grid = {}
  for i = 1, DIM do
    Grid[i] = {}
    for j = 1, DIM do
      Grid[i][j] = {
        options = {},
        collapsed = false,
      }
      for n = 1, #tiles do table.insert(Grid[i][j].options, tiles[n]) end
    end
  end

  UpdatePosabilities()
end

-- Each frame, update the grid
function love.update(dt) UpdateGrid() end

function UpdateGrid()
  -- If all the grid is collapsed, then return and no update is needed.
  local completed = true
  for i = 1, DIM do for j = 1, DIM do if not Grid[i][j].collapsed then completed = false end end end
  if completed then return end

  UpdatePosabilities()

  -- Get an array of all the grid cells with the least number of options available.
  local selectedOnes = GetSortedGrid()

  -- Choose one of the selectedOnes.
  local chosen = math.random(1, #selectedOnes)
  local chosenGrid = Grid[selectedOnes[chosen][1]][selectedOnes[chosen][2]]

  -- Choose a random option to the selected cell and collapse it.
  local chosenTileIndex = math.random(1, #chosenGrid.options)
  chosenGrid.collapsed = true
  chosenGrid.tile = chosenGrid.options[chosenTileIndex]
end

-- Get array of grid cells with the least possible number of options.
function GetSortedGrid()
  local t = {}
  lowest = 1000
  for i = 1, DIM do
    for j = 1, DIM do
      if not Grid[i][j].collapsed then lowest = #Grid[i][j].options < lowest and #Grid[i][j].options or lowest end
    end
  end

  for i = 1, DIM do
    for j = 1, DIM do
      if not Grid[i][j].collapsed then if #Grid[i][j].options == lowest then table.insert(t, {i, j}) end end
    end
  end
  return t
end

-- Update the options of each grid's cell.
function UpdatePosabilities()
  -- Look at all the surrounding grid cells, check if the option can't go with it and remove it. 
  for i = 1, DIM do
    for j = 1, DIM do
      -- Keep track of the bad options in an array
      local bad = {}

      local grdOptions = Grid[i][j].options

      -- Down
      if Grid[i][j + 1] and Grid[i][j + 1].tile then
        for p, opt in ipairs(grdOptions) do
          if not opt:CanGoAbove(Grid[i][j + 1].tile) then table.insert(bad, opt) end
        end
      end
      Grid[i][j].options = FilterBadOnesIfThere(Grid[i][j].options, bad)

      -- Up
      if Grid[i][j - 1] and Grid[i][j - 1].tile then
        for p, opt in ipairs(grdOptions) do
          if not opt:CanGoBellow(Grid[i][j - 1].tile) then table.insert(bad, opt) end
        end
      end
      Grid[i][j].options = FilterBadOnesIfThere(Grid[i][j].options, bad)

      -- Right
      if Grid[i - 1] and Grid[i - 1][j].tile then
        for p, opt in ipairs(grdOptions) do
          if not opt:CanGoOnRight(Grid[i - 1][j].tile) then table.insert(bad, opt) end
        end
      end
      Grid[i][j].options = FilterBadOnesIfThere(Grid[i][j].options, bad)

      -- Left
      if Grid[i + 1] and Grid[i + 1][j].tile then
        for p, opt in ipairs(grdOptions) do
          if not opt:CanGoOnLeft(Grid[i + 1][j].tile) then table.insert(bad, opt) end
        end
      end
      Grid[i][j].options = FilterBadOnesIfThere(Grid[i][j].options, bad)
    end
  end
end

function love.draw()
  love.graphics.clear(0.16, 0.17, 0.2, 1)
  for i = 1, DIM do
    for j = 1, DIM do
      -- If the tile is collapsed then draw else draw a stroke around its position
      if Grid[i][j].tile then
        Grid[i][j].tile:Draw((i - 1) * WIDTH / DIM, (j - 1) * HEIGHT / DIM)
      else
        love.graphics.rectangle("line", (i - 1) * WIDTH / DIM, (j - 1) * HEIGHT / DIM, WIDTH / DIM, HEIGHT / DIM)
      end
    end
  end
  love.graphics.setColor(1, 1, 1, 1)

  DisplayFPS()
end

function DisplayFPS()
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
  love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key) if key == 'escape' then love.event.quit() end end
