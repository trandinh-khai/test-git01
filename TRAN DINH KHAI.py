import pygame
import heapq

WIDTH, HEIGHT = 900, 600
BG_COLOR = (255, 255, 240)

NUM_POLES = 6
RADIUS = 35
SPACING = 120
POLE_HEIGHT = 250
POLE_WIDTH = 15
MARGIN_TOP = 50
MARGIN_BOTTOM = 50
HIGHLIGHT_OFFSET = 20  

COLORS = [(255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0),
          (255, 165, 0), (255, 20, 147)]

pygame.init()
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Color Sorting Game")
font = pygame.font.Font(None, 40)

class Pole:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.rings = []
        self.selected = False 

    def draw(self, screen):
        pygame.draw.rect(screen, (100, 100, 100), (self.x - POLE_WIDTH // 2, self.y - POLE_HEIGHT, POLE_WIDTH, POLE_HEIGHT))
        for i, color in enumerate(self.rings):
            # Calculate the size based on the index
            size_factor = 1 + (len(self.rings) - i) * 0.1  # Increase size for lower rings
            radius = int(RADIUS * size_factor)
            offset = -HIGHLIGHT_OFFSET if self.selected and i == len(self.rings) - 1 else 0
            pygame.draw.circle(screen, color, (self.x, self.y - i * (RADIUS + 5) + offset), radius)

    def add_ring(self, ring):
        if len(self.rings) < 4:
            self.rings.append(ring)
            return True
        return False

    def can_remove_ring(self):
        return len(self.rings) > 0

    def remove_ring(self):
        if self.can_remove_ring():
            return self.rings.pop()
        return None


def check_win():
    for pole in poles:
        if len(pole.rings) == 4 and len(set(pole.rings)) == 1:
            continue
        elif len(pole.rings) == 0:
            continue
        else:
            return False
    return True

def reset_game():
    global poles, selected_pole
    poles = [Pole(150 + i * SPACING, HEIGHT - MARGIN_BOTTOM - 100) for i in range(NUM_POLES)]
    poles[0].rings = [COLORS[0], COLORS[1], COLORS[2], COLORS[3]]
    poles[1].rings = [COLORS[3], COLORS[2], COLORS[1], COLORS[0]]
    poles[2].rings = [COLORS[1], COLORS[0], COLORS[3], COLORS[2]]
    poles[3].rings = []  # Cột trống
    poles[4].rings = []  # Cột trống
    poles[5].rings = [COLORS[2], COLORS[3], COLORS[0], COLORS[1]]
    selected_pole = None

reset_game()
selected_pole = None
running = True

while running:
    screen.fill(BG_COLOR)
    
    pygame.draw.rect(screen, (200, 200, 200), (0, MARGIN_TOP - 10, WIDTH, 10))  
    pygame.draw.rect(screen, (200, 200, 200), (0, HEIGHT - MARGIN_BOTTOM, WIDTH, 10))  
    
    for pole in poles:
        pole.draw(screen)
    pygame.display.flip()
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            for i, pole in enumerate(poles):
                if pole.x - RADIUS <= x <= pole.x + RADIUS and pole.y - POLE_HEIGHT <= y <= pole.y:
                    if selected_pole is None:
                        
                        
                        if pole.can_remove_ring():
                            selected_pole = i
                            pole.selected = True  
                    else:
                        if selected_pole != i:
                            ring = poles[selected_pole].remove_ring()
                            if ring is not None:
                                if not poles[i].add_ring(ring):
                                    poles[selected_pole].add_ring(ring)     
                            poles[selected_pole].selected = False  
                        selected_pole = None
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_r:
                reset_game()
            elif event.key == pygame.K_ESCAPE:
                running = False
    
    if check_win():
        screen.fill((0, 255, 0))
        text = font.render("YOU WIN!", True, (0, 0, 0))
        screen.blit(text, (WIDTH//2 - 50, HEIGHT//2 - 20))
        pygame.display.flip()
        pygame.time.delay(2000)
        running = False

pygame.quit()