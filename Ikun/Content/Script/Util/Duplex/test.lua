
local duplex = duplex.create()

duplex:dinsert(1001, {id = 1001, name = 'qqq'})
duplex:dinsert(1002, {id = 1002, name = 'www'})
duplex:dinsert(1003, {id = 1003, name = 'eee'})
duplex:dinsert(1004, {id = 1004, name = 'rrr'})
duplex:dinsert(1005, {id = 1005, name = 'ttt'})

duplex:dremove(1002)
duplex:dremove(1004)

duplex:dinsert(1006, {id = 1006, name = 'aaa'})
duplex:dinsert(1007, {id = 1007, name = 'sss'})
duplex:dinsert(1008, {id = 1008, name = 'ddd'})

-- log.debug('dp', duplex:dlength())

-- for _, k, v in duplex:diter() do
--     log.debug('dp ', k, v.id, v.name)
-- end
