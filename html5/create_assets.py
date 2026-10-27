from PIL import Image, ImageDraw, ImageFilter
import random, math
from pathlib import Path
O=Path(__file__).parent/'assets'
O.mkdir(exist_ok=True)

# Hand-crafted, internally generated pixel character art. No copyrighted assets.
def sprite(name, kind, palette):
    im=Image.new('RGBA',(52,74)); d=ImageDraw.Draw(im)
    ink='#17191c'; outline='#171b1f'
    metal=palette.get('metal','#879e9a'); metal_hi=palette.get('hi','#d0d6c4'); metal_shadow=palette.get('shadow','#40565d')
    cloth=palette.get('cloth','#314c43'); cloth_hi=palette.get('cloth_hi','#668775')
    skin=palette.get('skin','#c29d72'); skin_hi=palette.get('skin_hi','#ebc29a')
    # utility rect/polygon with dark ink outline
    def box(v, fill, stroke=ink, width=1): d.rectangle(v,fill=fill,outline=stroke,width=width)
    def poly(p,fill): d.polygon(p,fill=fill);d.line(p+[p[0]],fill=ink,width=1)
    # silhouette boots legs / belts
    box((15,53,23,68),'#313237'); box((29,53,37,68),'#292c31')
    box((13,65,24,71),'#3c3631'); box((28,65,40,71),'#3c3631')
    d.line((16,67,23,67), fill='#827561',width=2)
    d.line((30,67,39,67), fill='#827561',width=2)
    # cape long behind
    poly([(12,21),(9,32),(10,59),(13,68),(17,59),(20,40)],cloth)
    poly([(34,21),(42,27),(45,61),(39,64),(34,44)],metal_shadow)
    # waist and tunic
    poly([(18,39),(34,39),(39,57),(27,60),(13,57)],cloth)
    d.line((17,44,32,45),fill=cloth_hi,width=2)
    d.line((18,49,19,58),fill=cloth_hi,width=1)
    # torso
    poly([(15,22),(23,19),(34,20),(39,26),(36,45),(17,44),(12,31)],metal_shadow)
    poly([(19,24),(28,21),(35,26),(33,41),(19,41)],metal)
    d.line((22,26,31,29),fill=metal_hi,width=3)
    d.line((23,31,23,39),fill=metal_hi,width=2)
    box((14,41,37,45),'#513c2a'); d.rectangle((25,41,29,45),fill='#c9a65f')
    # arms and pauldrons
    poly([(13,24),(18,21),(23,25),(20,35),(11,34)],metal)
    poly([(34,23),(41,25),(42,35),(34,35),(31,29)],metal)
    d.line((13,27,19,26),fill=metal_hi,width=2)
    d.line((36,26,40,28),fill=metal_hi,width=2)
    # head/face hair
    box((22,12,33,23),skin)
    d.rectangle((24,14,32,15),fill=skin_hi)
    d.point((31,18), fill='#1a1e22')
    d.line((29,21,32,21),fill='#673e37',width=1)
    # shield and weapon variations
    if kind in ('dwarf','hero'):
        # helmet + beard
        poly([(19,11),(20,5),(26,2),(34,5),(37,13),(33,15),(23,15)],metal)
        d.line((22,7,34,8),fill=metal_hi,width=2)
        poly([(22,19),(24,30),(29,37),(33,28),(33,20)],'#9b5838')
        d.line((28,21,28,33),fill='#d7955e',width=2)
        # raised axe in back
        d.line((43,14,43,52), fill='#251e19',width=5)
        d.line((43,14,43,52), fill='#a88750',width=2)
        poly([(43,9),(51,7),(50,22),(44,23),(43,19)],'#bac4ba')
        d.line((47,9,49,19),fill='#e3d9b5',width=1)
        # shield detailed
        poly([(6,30),(17,28),(20,36),(19,52),(12,59),(5,51)],'#70502f')
        poly([(8,33),(15,31),(17,37),(16,50),(12,55),(8,49)],'#8b6336')
        d.line((12,32,12,53),fill='#c4a168',width=2)
        d.ellipse((9,39,15,45),fill='#d7d0b1',outline=ink,width=1)
        d.line((6,33,17,32),fill='#b9b9a3',width=2)
    elif kind=='zeno':
        # long silver hair cape strands
        poly([(19,7),(24,2),(33,3),(38,11),(40,32),(35,39),(34,14),(22,14),(18,34),(16,29)],'#b7bfc2')
        d.line((18,8,18,28), fill='#eff2e8',width=2)
        d.line((36,7,39,29), fill='#879ba6',width=2)
        # iron sword
        poly([(43,1),(46,1),(47,35),(42,35)],'#d0d9d4')
        d.line((44,4,44,30),fill='#f3f6ec',width=1)
        d.line((38,35,50,35),fill='#bc9259',width=3)
        d.line((44,37,44,50),fill='#665036',width=3)
        # robust shield
        poly([(4,26),(18,27),(22,34),(19,53),(12,61),(5,54)],'#858f8c')
        poly([(8,30),(17,31),(18,38),(16,51),(12,56),(8,51)],'#785638')
        d.line((12,31,12,55),fill='#c3c9be',width=2)
        d.ellipse((9,38,15,44),fill='#adb5b0',outline=ink)
    elif kind=='archer':
        poly([(16,20),(16,8),(25,4),(34,10),(40,22),(33,24),(23,19)],cloth)
        poly([(20,10),(24,7),(36,15),(35,21),(22,21)],'#28362f')
        d.line((36,17,43,17),fill='#d0bb83',width=2)
        # bow
        d.arc((1,13,15,56),start=265,end=95,fill='#c89b5f',width=3)
        d.line((8,14,8,56),fill='#ece2b6',width=1)
        d.line((8,34,30,34),fill='#d8d7bc',width=2)
        d.polygon([(30,32),(35,34),(30,36)],fill='#e1dac0')
    elif kind=='bandit':
        poly([(18,11),(22,6),(35,10),(40,21),(34,25),(22,21)],'#3c3330')
        d.line((20,13,37,17),fill='#77634b',width=2)
        d.line((44,19,44,60),fill='#6c4e2d',width=5)
        d.ellipse((38,15,49,29),fill='#817057',outline=ink,width=2)
        d.line((39,21,46,20),fill='#c0a788',width=2)
    elif kind=='goblin':
        # goblin green face ears long nose
        d.polygon([(19,15),(10,10),(16,22)],fill='#72945b')
        d.polygon([(34,15),(43,12),(36,23)],fill='#72945b')
        d.rectangle((21,13,35,25),fill='#809e64',outline=ink)
        d.polygon([(31,19),(38,23),(31,24)],fill='#779552')
        d.point((31,17),fill='#edce6b')
        d.line((25,24,33,24),fill='#423b31',width=2)
        d.line((44,20,44,59),fill='#664e36',width=5)
        d.ellipse((40,16,50,28),fill='#85796a',outline=ink,width=2)
    elif kind=='scrap':
        d.polygon([(19,13),(8,11),(18,24)],fill='#6a8f61')
        d.polygon([(34,15),(42,10),(38,23)],fill='#6a8f61')
        d.rectangle((21,13,36,25),fill='#83a76e',outline=ink)
        d.point((32,18), fill='#ffe089')
        poly([(14,19),(29,19),(32,35),(22,43),(9,32)],'#8a8b76')
        d.line((15,24,25,24),fill='#c1c1aa',width=2)
        # iron shield / bucket
        box((3,29,18,52),'#7b827b'); d.line((7,32,15,33),fill='#c7c7b5',width=2)
        d.line((10,36,11,49),fill='#3a4a49',width=2)
        d.line((42,21,48,48),fill='#9e8c6c',width=4)
    elif kind=='knife':
        d.polygon([(20,14),(8,10),(18,23)],fill='#80a36a')
        d.polygon([(35,14),(44,11),(37,23)],fill='#80a36a')
        d.rectangle((22,13,35,25),fill='#8dac6f',outline=ink)
        d.point((32,18),fill='#e9d484')
        d.line((1,30,15,48),fill='#b8c2bb',width=4)
        d.line((36,42,50,29),fill='#b8c2bb',width=4)
        d.line((4,33,15,47),fill='#e4e6d0',width=1)
        d.line((37,42,48,32),fill='#e4e6d0',width=1)
    elif kind=='boss':
        poly([(17,13),(9,8),(18,25)],'#a6a05a')
        poly([(34,14),(47,7),(40,27)],'#a6a05a')
        d.rectangle((19,11,37,29),fill='#94a362',outline=ink)
        d.line((22,17,37,17),fill='#382f26',width=3)
        d.point((34,20),fill='#f0b85b');d.point((26,20),fill='#f0b85b')
        poly([(16,27),(36,26),(41,49),(12,50)],'#8d3c32')
        d.line((18,30,33,31),fill='#c07652',width=3)
        # crown horns
        poly([(21,13),(20,4),(25,10),(30,2),(36,12)],'#be9b4f')
        # boss sword
        d.line((45,2,43,40),fill='#ced1c4',width=5)
        d.line((44,6,44,34),fill='#f0f0cf',width=1)
        d.line((37,40,49,42),fill='#9a7045',width=4)
        d.line((43,43,43,61),fill='#64472d',width=4)
    im.save(O/f'{name}.png')

sprite('brokk','dwarf',dict(metal='#6f8a98',hi='#c9dad9',shadow='#3e5960',cloth='#4a6b66',cloth_hi='#90a99f'))
sprite('zeno','zeno',dict(metal='#8e9da5',hi='#d7e5e6',shadow='#485861',cloth='#28473f',cloth_hi='#5f8c77'))
sprite('bandit_archer','archer',dict(metal='#5e6256',hi='#b8b39d',shadow='#3c3d39',cloth='#5c5a3a',cloth_hi='#b1a672'))
sprite('bandit_club','bandit',dict(metal='#6f5750',hi='#b4a296',shadow='#42302b',cloth='#564238',cloth_hi='#917356'))
sprite('goblin_club','goblin',dict(metal='#69744a',hi='#adb38b',shadow='#3d4a32',cloth='#72523c',cloth_hi='#b08555',skin='#8bae6a'))
sprite('goblin_scrap','scrap',dict(metal='#8c8b76',hi='#cac9aa',shadow='#485048',cloth='#636547',cloth_hi='#a1a17f',skin='#80a66e'))
sprite('goblin_archer','archer',dict(metal='#66845a',hi='#acbe8c',shadow='#3c573a',cloth='#53634a',cloth_hi='#a0b075',skin='#8eae76'))
sprite('goblin_knife','knife',dict(metal='#65885a',hi='#a1b68b',shadow='#3a533b',cloth='#684b4c',cloth_hi='#ad796a',skin='#8caf70'))
sprite('tripa_seca','boss',dict(metal='#907148',hi='#d5ba71',shadow='#493c33',cloth='#81362e',cloth_hi='#c57553',skin='#829d58'))

# Seeded original scenic pixel panoramas.
W,H=640,360
settings=[
 dict(id='floresta',sky=['#111f30','#254253','#6d5650'],mist='#8c8775',mount='#293a41',back='#172f32',fore='#101e26',moon=(500,55),type='forest'),
 dict(id='mata',sky=['#14232b','#314540','#817451'],mist='#b0aa83',mount='#384a3d',back='#243d32',fore='#192e29',moon=(486,45),type='forest'),
 dict(id='passagem',sky=['#1a1f2b','#3b3640','#8e6154'],mist='#96827b',mount='#524f50',back='#33313b',fore='#1c2530',moon=(140,58),type='ruins'),
 dict(id='covil',sky=['#130d1a','#28202a','#513333'],mist='#6b4d41',mount='#322c35',back='#25212c',fore='#16151e',moon=(518,56),type='cave'),
]
for idx,op in enumerate(settings):
    rnd=random.Random(1245+idx)
    im=Image.new('RGB',(W,H));pix=im.load()
    cs=[tuple(int(h[i:i+2],16) for i in (1,3,5)) for h in op['sky']]
    for y in range(H):
        t=y/(H-1)
        if t<.55: a,b,q=cs[0],cs[1],t/.55
        else:a,b,q=cs[1],cs[2],(t-.55)/.45
        for x in range(W):
            noise=(rnd.random()-.5)*7
            pix[x,y]=tuple(max(0,min(255,int(a[k]*(1-q)+b[k]*q+noise))) for k in range(3))
    d=ImageDraw.Draw(im)
    if idx!=3:
        mx,my=op['moon']; d.ellipse((mx-21,my-21,mx+21,my+21),fill='#e5cf99')
        d.ellipse((mx-15,my-17,mx+16,my+15),fill='#f6e9c7')
        for j in range(45):
            x=rnd.randrange(W);y=rnd.randrange(5,150)
            if abs(x-mx)<30 and abs(y-my)<30:continue
            d.point((x,y),fill=rnd.choice(['#bec7c4','#d5bd9d','#8f9ba6']))
    # distant mountain ridgelines
    peaks=[(0,223)]+[(x,rnd.randrange(149,239)) for x in range(0,W+50,43)]+[(W,300)]
    d.polygon(peaks+[(W,H),(0,H)],fill=op['mount'])
    for j in range(9):
        x=j*82-50; h=rnd.randrange(170,255)
        d.polygon([(x-60,310),(x,h),(x+60,310)],fill=op['back'])
    # terrace ground
    d.polygon([(0,274),(128,264),(254,290),(370,279),(520,270),(640,283),(640,H),(0,H)],fill=op['fore'])
    if op['type']=='forest':
        for j in range(38):
            x=rnd.randrange(-20,W+25); y=rnd.randrange(194,315); tall=rnd.randrange(38,126)
            trunk='#1c2427' if j%3 else '#292927'
            d.rectangle((x-2,y-tall//3,x+2,y+20), fill=trunk)
            color = rnd.choice(['#11282a','#173437','#243d37','#21322d','#183035'])
            d.polygon([(x,y-tall),(x-17,y-tall//2),(x-10,y-tall//2),(x-23,y-tall//4),(x,y-tall//2+26),(x+22,y-tall//4),(x+11,y-tall//2),(x+19,y-tall//2)],fill=color)
        # ruins: aged pillars with moss
        for x in [78,548]:
            d.rectangle((x,223,x+11,312),fill='#66635b')
            d.rectangle((x-6,220,x+18,226),fill='#8d816e')
            d.rectangle((x+2,240,x+5,270),fill='#474d4a')
            d.line((x,236,x+10,234),fill='#96a07e',width=2)
    elif op['type']=='ruins':
        for x in [25,95,531,607]:
            d.rectangle((x,174,x+22,324),fill='#504d4e')
            d.rectangle((x-5,169,x+27,181),fill='#797276')
            for y in [198,224,249,273,298]:d.line((x+1,y,x+20,y),fill='#35383d',width=2)
        d.line((40,178,122,181),fill='#73605f',width=13)
        d.line((524,181,632,167),fill='#73605f',width=13)
    else:
        # cave arch rocky stalactites, red veins
        d.polygon([(0,0),(640,0),(640,90),(580,55),(540,96),(493,34),(435,65),(388,19),(333,82),(277,25),(206,96),(151,29),(97,81),(28,32),(0,96)],fill='#15141c')
        for j in range(40):
            x=rnd.randrange(W); y=rnd.randrange(0,70)
            d.line((x,y,x+rnd.randrange(-13,14),y+rnd.randrange(25,65)),fill=rnd.choice(['#38242c','#3c2930','#4a3432']),width=2)
        for x in [54,564]:
            d.rectangle((x,219,x+14,320),fill='#6a5747')
            d.rectangle((x-4,213,x+18,225),fill='#9a7955')
            d.polygon([(x+7,214),(x-1,193),(x+7,176),(x+16,193)],fill='#da7841')
            d.polygon([(x+8,207),(x+4,196),(x+8,186),(x+12,196)],fill='#f3c777')
        d.ellipse((240,191,400,283), fill='#3b2834')
        d.ellipse((260,205,380,285), fill='#17151d')
    # broken cobblestones lower scene
    for j in range(180):
        x=rnd.randrange(W);y=rnd.randrange(284,357)
        c=rnd.choice(['#39403c','#303b3b','#444844','#525149']) if idx<2 else rnd.choice(['#494343','#534a44','#31333a','#373039'])
        ww=rnd.randrange(4,19);hh=rnd.randrange(2,7)
        d.line((x,y,x+ww,y),fill=c,width=hh//3+1)
        if j%5==0:d.line((x+ww//2,y+1,x+ww//2-2,y+5),fill='#27292a',width=1)
    im.save(O/(op['id']+'.jpg'),quality=88,subsampling=0)
print('Generated',list(x.name for x in O.iterdir()))
